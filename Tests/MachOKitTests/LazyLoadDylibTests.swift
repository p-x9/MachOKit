import XCTest
@testable import MachOKit

final class LazyLoadDylibTests: XCTestCase {
    // DYLD_CHAINED_PTR_64_OFFSET uses a four-byte stride for its next field.
    private let nextPointer = UInt64(2) << 51
    private let bind = UInt64(1) << 63

    func testMixedChainPreservesRebasesAndBinds() throws {
        try withFixups(words: [nextPointer | 0x1234, bind | nextPointer, 0x5678]) { pointers, reader in
            XCTAssertNotNil(pointers, reader)
            guard let pointers else { return }
            XCTAssertEqual(pointers.map(\.offset), [0x1000, 0x1008, 0x1010], reader)
            XCTAssertEqual(pointers.compactMap { $0.fixupInfo.bind?.ordinal }, [0], reader)
            XCTAssertEqual(pointers.compactMap { $0.fixupInfo.rebase?.target }, [0x1234, 0x5678], reader)
        }
    }

    func testBindOnlyChainRemainsReadable() throws {
        try withFixups(words: [bind | nextPointer, bind | 1], symbolsCount: 2) { pointers, reader in
            XCTAssertNotNil(pointers, reader)
            guard let pointers else { return }
            XCTAssertEqual(pointers.map(\.offset), [0x1000, 0x1008], reader)
            XCTAssertEqual(pointers.compactMap { $0.fixupInfo.bind?.ordinal }, [0, 1], reader)
        }
    }

    func testMixedChainRejectsInvalidBindOrdinal() throws {
        try withFixups(words: [nextPointer | 0x1234, bind | 1]) { pointers, reader in
            XCTAssertNil(pointers, reader)
        }
    }

    func testUnterminatedChainRemainsUnavailable() throws {
        try withFixups(words: [bind | nextPointer], chainOffset: 0x2FF8) { pointers, reader in
            XCTAssertNil(pointers, reader)
        }
    }

    private func withFixups(
        words: [UInt64],
        symbolsCount: UInt32 = 1,
        chainOffset: Int = 0x1000,
        check: ([DyldChainedFixupPointer]?, String) -> Void
    ) throws {
        let data = makeFixture(words: words, symbolsCount: symbolsCount, chainOffset: chainOffset)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("MachOKit-LazyLoad-\(UUID().uuidString)")
        try data.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let file = try MachOFile(url: url)
        XCTAssertEqual(file.lazyLoadDylibs.count, 1)
        let fileDylib = try XCTUnwrap(file.lazyLoadDylibs.first)
        check(fileDylib.fixups(in: file), "MachOFile")

        try data.withUnsafeBytes { bytes in
            let image = MachOImage(ptr: bytes.baseAddress!.assumingMemoryBound(to: mach_header.self))
            XCTAssertEqual(image.lazyLoadDylibs.count, 1)
            let imageDylib = try XCTUnwrap(image.lazyLoadDylibs.first)
            check(imageDylib.fixups(in: image), "MachOImage")
        }
    }

    private func makeFixture(words: [UInt64], symbolsCount: UInt32, chainOffset: Int) -> Data {
        // Matching file and VM offsets let the same fixture exercise both readers.
        let preferredLoadAddress: UInt64 = 0x1_0000_0000
        let linkeditOffset = 0x2000
        var data = Data(count: 0x3000)

        func store<Value>(_ value: Value, at offset: Int) {
            withUnsafeBytes(of: value) { bytes in
                data.replaceSubrange(offset ..< offset + bytes.count, with: bytes)
            }
        }

        var header = mach_header_64()
        header.magic = UInt32(MH_MAGIC_64)
        header.cputype = CPU_TYPE_ARM64
        header.filetype = UInt32(MH_DYLIB)
        header.ncmds = 4
        header.sizeofcmds = UInt32(3 * MemoryLayout<segment_command_64>.size + MemoryLayout<linkedit_data_command>.size)
        store(header, at: 0)

        var commandOffset = MemoryLayout<mach_header_64>.size
        for (index, name) in ["__TEXT", "__DATA", "__LINKEDIT"].enumerated() {
            var segment = segment_command_64()
            segment.cmd = UInt32(LC_SEGMENT_64)
            segment.cmdsize = UInt32(MemoryLayout<segment_command_64>.size)
            withUnsafeMutableBytes(of: &segment.segname) { bytes in
                bytes.copyBytes(from: name.utf8)
            }
            segment.vmaddr = preferredLoadAddress + UInt64(index * 0x1000)
            segment.vmsize = 0x1000
            segment.fileoff = UInt64(index * 0x1000)
            segment.filesize = 0x1000
            segment.maxprot = VM_PROT_READ | VM_PROT_WRITE
            segment.initprot = VM_PROT_READ | VM_PROT_WRITE
            store(segment, at: commandOffset)
            commandOffset += MemoryLayout<segment_command_64>.size
        }

        var command = linkedit_data_command()
        command.cmd = UInt32(LC_LAZY_LOAD_DYLIB_INFO)
        command.cmdsize = UInt32(MemoryLayout<linkedit_data_command>.size)
        command.dataoff = UInt32(linkeditOffset)
        command.datasize = 0x100
        store(command, at: commandOffset)

        var lazy = LazyLoadDylib.Layout()
        lazy.loadPathOffset = UInt32(MemoryLayout<LazyLoadDylib.Layout>.size)
        lazy.flagImageOffset = 0x1100
        lazy.pointerFormat = UInt16(DYLD_CHAINED_PTR_64_OFFSET)
        lazy.chainStartImageOffset = UInt32(chainOffset)
        lazy.symbolsCount = symbolsCount
        lazy.symbolStringArrayOffset = 0x40
        store(lazy, at: linkeditOffset)

        for (offset, string) in [
            (Int(lazy.loadPathOffset), "/usr/lib/libLazyFixture.dylib\0"),
            (0x50, "_first\0"),
            (0x60, "_second\0"),
        ] {
            let start = linkeditOffset + offset
            data.replaceSubrange(start ..< start + string.utf8.count, with: string.utf8)
        }
        store(UInt32(0x50), at: linkeditOffset + 0x40)
        store(UInt32(0x60), at: linkeditOffset + 0x44)

        for (index, word) in words.enumerated() {
            store(word, at: chainOffset + index * MemoryLayout<UInt64>.size)
        }
        return data
    }
}
