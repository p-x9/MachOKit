import XCTest
import MachOKitC
@_spi(Support) @testable import MachOKit

final class StubDecoderTests: XCTestCase {
    func testArm64StubViaSlot() {
        let address: UInt64 = 0x1_0000_4000
        let slot: UInt64 = 0x1_0012_3458
        let instructions = [
            adrp(register: 16, from: address, to: slot),
            UInt32(0xF940_0210 | (((slot & 0xFFF) / 8) << 10)),
            0xD61F_0200
        ]
        XCTAssertEqual(
            StubDecoder.decode(data(instructions), address: address, cpuType: .arm64),
            .viaSlot(slot)
        )
    }

    func testArm64eStubViaSlot() {
        let address: UInt64 = 0x1_0020_0000
        let slot: UInt64 = 0x1_001F_F678
        let instructions = [
            adrp(register: 17, from: address, to: slot),
            UInt32(0x9100_0231 | ((slot & 0xFFF) << 10)),
            0xF940_0230,
            0xD71F_0A11
        ]
        XCTAssertEqual(
            StubDecoder.decode(data(instructions), address: address, cpuType: .arm64),
            .viaSlot(slot)
        )
    }

    func testArm64_32StubViaSlot() {
        let address: UInt64 = 0x4000
        let slot: UInt64 = 0x9234
        let instructions = [
            adrp(register: 16, from: address, to: slot),
            UInt32(0xB940_0210 | (((slot & 0xFFF) / 4) << 10)),
            0xD61F_0200
        ]
        XCTAssertEqual(
            StubDecoder.decode(data(instructions), address: address, cpuType: .arm64_32),
            .viaSlot(slot)
        )
    }

    func testArm64DirectForms() {
        let address: UInt64 = 0x1_0000_0000
        let target: UInt64 = 0x1_0001_2340
        let longForm = [
            adrp(register: 16, from: address, to: target),
            UInt32(0x9100_0210 | ((target & 0xFFF) << 10)),
            0xD61F_0200,
            0xD420_0020
        ]
        XCTAssertEqual(
            StubDecoder.decode(data(longForm), address: address, cpuType: .arm64),
            .direct(target)
        )

        let branchTarget = address - 0x100
        let immediate = UInt32(truncatingIfNeeded: Int64(branchTarget) - Int64(address)) >> 2
        let shortForm: [UInt32] = [
            0x1400_0000 | (immediate & 0x03FF_FFFF),
            0xD503_201F,
            0xD420_0000
        ]
        XCTAssertEqual(
            StubDecoder.decode(data(shortForm), address: address, cpuType: .arm64),
            .direct(branchTarget)
        )
    }

    func testX86_64StubForms() {
        let address: UInt64 = 0x1000
        XCTAssertEqual(
            StubDecoder.decode(
                Data([0xFF, 0x25, 0x10, 0x00, 0x00, 0x00]),
                address: address,
                cpuType: .x86_64
            ),
            .viaSlot(0x1016)
        )
        XCTAssertEqual(
            StubDecoder.decode(
                Data([0xE9, 0xF0, 0xFF, 0xFF, 0xFF]),
                address: address,
                cpuType: .x86_64
            ),
            .direct(0x0FF5)
        )
    }

    func testObjectiveCStub() {
        let address: UInt64 = 0x1_0000_4000
        let selectorReference: UInt64 = 0x1_0002_3458
        let slot: UInt64 = 0x1_0003_2678
        let instructions: [UInt32] = [
            adrp(register: 1, from: address, to: selectorReference),
            UInt32(0xF940_0021 | (((selectorReference & 0xFFF) / 8) << 10)),
            adrp(register: 16, from: address + 8, to: slot),
            UInt32(0xF940_0210 | (((slot & 0xFFF) / 8) << 10)),
            0xD61F_0200,
            0xD503_201F,
            0xD503_201F,
            0xD503_201F
        ]
        let bytes = data(instructions)
        XCTAssertEqual(
            StubDecoder.selectorReference(in: bytes, stubAddress: address),
            selectorReference
        )
        XCTAssertEqual(
            StubDecoder.decode(
                bytes.subdata(in: 8..<bytes.count),
                address: address + 8,
                cpuType: .arm64
            ),
            .viaSlot(slot)
        )
    }

    func testMalformedAndTruncatedStubsAreUnknown() {
        XCTAssertEqual(
            StubDecoder.decode(Data([0xFF]), address: .max, cpuType: .x86_64),
            .unknown
        )
        XCTAssertEqual(
            StubDecoder.decode(data([0x1400_0000, 0]), address: 0, cpuType: .arm64),
            .unknown
        )
        XCTAssertNil(
            StubDecoder.selectorReference(in: Data(repeating: 0, count: 7), stubAddress: 0)
        )
    }

    func testFileAndImageAPIsDecodeSymbolStubSection() throws {
        let baseAddress: UInt64 = 0x1_0000_0000
        let stubAddress = baseAddress + 0x200
        let slot = baseAddress + 0x458
        let instructions = [
            adrp(register: 16, from: stubAddress, to: slot),
            UInt32(0xF940_0210 | (((slot & 0xFFF) / 8) << 10)),
            0xD61F_0200
        ]
        let fixture = machOFixture(
            sectionName: "__stubs",
            sectionType: UInt32(S_SYMBOL_STUBS),
            reserved1: 7,
            reserved2: 12,
            contents: data(instructions)
        )

        try withFile(fixture) { file in
            let section = try XCTUnwrap(file.sections.first)
            XCTAssertEqual(section.data(in: file), data(instructions))
            let stub = try XCTUnwrap(section.stubs(in: file)?.first)
            XCTAssertEqual(stub.address, stubAddress)
            XCTAssertEqual(stub.size, 12)
            XCTAssertEqual(stub.indirectSymbolIndex, 7)
            XCTAssertEqual(stub.branch, .viaSlot(slot))
        }

        fixture.withUnsafeBytes { bytes in
            let image = MachOImage(
                ptr: bytes.baseAddress!.assumingMemoryBound(to: mach_header.self)
            )
            let section = image.sections.first!
            XCTAssertEqual(section.data(in: image), data(instructions))
            let stub = section.stubs(in: image)?.first
            XCTAssertEqual(stub?.address, stubAddress)
            XCTAssertEqual(stub?.indirectSymbolIndex, 7)
            XCTAssertEqual(stub?.branch, .viaSlot(slot))
        }
    }

    func testZeroStubSizeIsRejectedWithoutDivisionByZero() {
        var layout = section_64()
        layout.size = 12
        layout.flags = UInt32(S_SYMBOL_STUBS)
        layout.reserved2 = 0
        let section = Section64(layout: layout)
        XCTAssertNil(section.stubSize)
        XCTAssertNil(section.numberOfIndirectSymbols)
    }

    func testFileAPIDecodesObjectiveCStubSection() throws {
        let baseAddress: UInt64 = 0x1_0000_0000
        let stubAddress = baseAddress + 0x200
        let selectorReference = baseAddress + 0x458
        let slot = baseAddress + 0x678
        let instructions: [UInt32] = [
            adrp(register: 1, from: stubAddress, to: selectorReference),
            UInt32(0xF940_0021 | (((selectorReference & 0xFFF) / 8) << 10)),
            adrp(register: 16, from: stubAddress + 8, to: slot),
            UInt32(0xF940_0210 | (((slot & 0xFFF) / 8) << 10)),
            0xD61F_0200,
            0xD503_201F,
            0xD503_201F,
            0xD503_201F
        ]
        let fixture = machOFixture(
            sectionName: "__objc_stubs",
            sectionType: UInt32(S_REGULAR),
            reserved1: 0,
            reserved2: 0,
            contents: data(instructions),
            selector: "setObject:forKey:"
        )

        try withFile(fixture) { file in
            let section = try XCTUnwrap(file.sections.first)
            let decoded = try XCTUnwrap(section.objcStubs(in: file)?.first)
            XCTAssertEqual(decoded.stub.address, stubAddress)
            XCTAssertEqual(decoded.stub.size, 32)
            XCTAssertNil(decoded.stub.indirectSymbolIndex)
            XCTAssertEqual(decoded.stub.branch, .viaSlot(slot))
            XCTAssertEqual(decoded.selectorReference, selectorReference)
            XCTAssertEqual(decoded.selector(in: file), "setObject:forKey:")
        }

        var loadedFixture = fixture
        loadedFixture.withUnsafeMutableBytes { bytes in
            let selectorPointer = bytes.baseAddress!.advanced(by: 0x500)
            bytes.storeBytes(
                of: UInt64(UInt(bitPattern: selectorPointer)).littleEndian,
                toByteOffset: 0x458,
                as: UInt64.self
            )
            let image = MachOImage(
                ptr: bytes.baseAddress!.assumingMemoryBound(to: mach_header.self)
            )
            let section = image.sections.first!
            let decoded = section.objcStubs(in: image)?.first
            XCTAssertEqual(decoded?.selector(in: image), "setObject:forKey:")
        }
    }

    private func adrp(register: UInt32, from pc: UInt64, to target: UInt64) -> UInt32 {
        let delta = Int64(target & ~UInt64(0xFFF)) - Int64(pc & ~UInt64(0xFFF))
        let immediate = UInt64(bitPattern: delta >> 12) & 0x1F_FFFF
        let immlo = UInt32(immediate & 0x3) << 29
        let immhi = UInt32((immediate >> 2) & 0x7_FFFF) << 5
        return 0x9000_0000 | immlo | immhi | register
    }

    private func data(_ instructions: [UInt32]) -> Data {
        instructions.reduce(into: Data()) { result, instruction in
            var instruction = instruction.littleEndian
            withUnsafeBytes(of: &instruction) { result.append(contentsOf: $0) }
        }
    }

    private func machOFixture(
        sectionName: String,
        sectionType: UInt32,
        reserved1: UInt32,
        reserved2: UInt32,
        contents: Data,
        selector: String? = nil
    ) -> Data {
        let sectionOffset = 0x200
        let baseAddress: UInt64 = 0x1_0000_0000
        let selectorReferenceOffset = 0x458
        let selectorOffset = 0x500
        let selectorData = selector.map { Data($0.utf8) + Data([0]) }
        let dataSize = selectorData.map { selectorOffset + $0.count }
            ?? sectionOffset + contents.count
        var result = Data(repeating: 0, count: dataSize)

        func put<T>(_ value: T, at offset: Int) {
            var value = value
            withUnsafeBytes(of: &value) {
                result.replaceSubrange(offset..<offset + $0.count, with: $0)
            }
        }

        var header = mach_header_64()
        header.magic = MH_MAGIC_64
        header.cputype = CPU_TYPE_ARM64
        header.cpusubtype = CPU_SUBTYPE_ARM64_ALL
        header.filetype = UInt32(MH_DYLIB)
        header.ncmds = 1
        header.sizeofcmds = UInt32(
            MemoryLayout<segment_command_64>.size
                + MemoryLayout<section_64>.size * (selector == nil ? 1 : 3)
        )
        put(header, at: 0)

        var segment = segment_command_64()
        segment.cmd = UInt32(LC_SEGMENT_64)
        segment.cmdsize = header.sizeofcmds
        segment.vmaddr = baseAddress
        segment.vmsize = UInt64(result.count)
        segment.fileoff = 0
        segment.filesize = UInt64(result.count)
        segment.nsects = selector == nil ? 1 : 3
        withUnsafeMutableBytes(of: &segment.segname) {
            $0.copyBytes(from: "__TEXT".utf8)
        }
        put(segment, at: MemoryLayout<mach_header_64>.size)

        var section = section_64()
        withUnsafeMutableBytes(of: &section.sectname) {
            $0.copyBytes(from: sectionName.utf8)
        }
        withUnsafeMutableBytes(of: &section.segname) {
            $0.copyBytes(from: "__TEXT".utf8)
        }
        section.addr = baseAddress + UInt64(sectionOffset)
        section.size = UInt64(contents.count)
        section.offset = UInt32(sectionOffset)
        section.flags = sectionType
        section.reserved1 = reserved1
        section.reserved2 = reserved2
        put(
            section,
            at: MemoryLayout<mach_header_64>.size + MemoryLayout<segment_command_64>.size
        )
        result.replaceSubrange(sectionOffset..<sectionOffset + contents.count, with: contents)

        if let selectorData {
            var selrefs = section_64()
            withUnsafeMutableBytes(of: &selrefs.sectname) {
                $0.copyBytes(from: "__objc_selrefs".utf8)
            }
            withUnsafeMutableBytes(of: &selrefs.segname) {
                $0.copyBytes(from: "__DATA_CONST".utf8)
            }
            selrefs.addr = baseAddress + UInt64(selectorReferenceOffset)
            selrefs.size = UInt64(MemoryLayout<UInt64>.size)
            selrefs.offset = UInt32(selectorReferenceOffset)
            selrefs.flags = UInt32(S_LITERAL_POINTERS)
            put(
                selrefs,
                at: MemoryLayout<mach_header_64>.size
                    + MemoryLayout<segment_command_64>.size
                    + MemoryLayout<section_64>.size
            )

            var methname = section_64()
            withUnsafeMutableBytes(of: &methname.sectname) {
                $0.copyBytes(from: "__objc_methname".utf8)
            }
            withUnsafeMutableBytes(of: &methname.segname) {
                $0.copyBytes(from: "__TEXT".utf8)
            }
            methname.addr = baseAddress + UInt64(selectorOffset)
            methname.size = UInt64(selectorData.count)
            methname.offset = UInt32(selectorOffset)
            methname.flags = UInt32(S_CSTRING_LITERALS)
            put(
                methname,
                at: MemoryLayout<mach_header_64>.size
                    + MemoryLayout<segment_command_64>.size
                    + MemoryLayout<section_64>.size * 2
            )

            put(baseAddress + UInt64(selectorOffset), at: selectorReferenceOffset)
            result.replaceSubrange(
                selectorOffset..<selectorOffset + selectorData.count,
                with: selectorData
            )
        }
        return result
    }

    private func withFile(_ data: Data, body: (MachOFile) throws -> Void) throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try data.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        try body(MachOFile(url: url))
    }
}
