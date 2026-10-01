import XCTest
@testable import MachOKit
import MachOKitC

/// Covers how a dyld cache header answers the architecture it was built for.
///
/// Two sources exist, and the header size is what picks between them. Until
/// macOS 26 the architecture was encoded only in `magic`; macOS 27 added an
/// explicit `cputype` / `cpusubtype` pair, because `"arm64ex1"` fills the 16
/// byte `magic` field exactly and a longer name would no longer fit.
final class DyldCacheHeaderArchitectureTests: XCTestCase {
    /// `mappingOffset` — and so the header size — of a macOS 27.0 (26A428) cache.
    private static let mappingOffsetWithArchitecture: UInt32 = 0x238

    /// `mappingOffset` of a macOS 26 cache, which ends before `cputype`.
    private static let mappingOffsetWithoutArchitecture: UInt32 = 0x228

    /// `CPU_SUBTYPE_ARM64E_X1` as it is actually written in a Mach-O header:
    /// the subtype plus the versioned-ptrauth-ABI flag in the top bit.
    private static let arm64eX1WithPtrAuthFlag = cpu_subtype_t(bitPattern: 0x8000_000C)

    private func makeHeader(
        magic: String,
        mappingOffset: UInt32,
        cpuType: cpu_type_t = 0,
        cpuSubType: cpu_subtype_t = 0
    ) -> DyldCacheHeader {
        var layout = dyld_cache_header()
        withUnsafeMutableBytes(of: &layout.magic) { buffer in
            for (index, byte) in magic.utf8.enumerated() where index < buffer.count {
                buffer[index] = byte
            }
        }
        layout.mappingOffset = mappingOffset
        layout.cputype = cpuType
        layout.cpusubtype = cpuSubType
        return DyldCacheHeader(layout: layout)
    }

    /// The modelled offset of the new pair must match where it sits in a real
    /// cache. Everything else here is downstream of this number: `hasProperty`
    /// compares it against `mappingOffset`, so a wrong offset silently reads
    /// the pair out of an older cache's mapping table instead.
    func testArchitectureFieldsBeginWhereTheOlderHeaderEnded() {
        XCTAssertEqual(
            MemoryLayout<dyld_cache_header>.offset(of: \.cputype),
            Int(Self.mappingOffsetWithoutArchitecture)
        )
        XCTAssertEqual(
            MemoryLayout<dyld_cache_header>.offset(of: \.cpusubtype),
            Int(Self.mappingOffsetWithoutArchitecture) + 4
        )
    }

    /// A macOS 27 cache states its architecture outright.
    func testArchitectureIsReadFromTheHeaderFields() {
        let header = makeHeader(
            magic: "dyld_v1arm64ex1",
            mappingOffset: Self.mappingOffsetWithArchitecture,
            cpuType: CPU_TYPE_ARM64,
            cpuSubType: Self.arm64eX1WithPtrAuthFlag
        )

        XCTAssertNotNil(header.cpu)
        XCTAssertEqual(header.cpu?.type, .arm64)
        // The ptrauth ABI flag in the top bit must not reach the subtype lookup.
        XCTAssertEqual(header.cpu?.subtype, .arm64(.arm64e_x1))
        XCTAssertEqual(header._resolvedCPU, header.cpu)
        XCTAssertEqual(
            header._resolvedCPU?.subtypeRawValue,
            Self.arm64eX1WithPtrAuthFlag
        )
        XCTAssertEqual(header._cpuType, .arm64)
        XCTAssertEqual(header._cpuSubType, .arm64(.arm64e_x1))
    }

    /// A pre-macOS-27 header stops before the pair, so it must not be read —
    /// those bytes belong to the mapping table there.
    func testOlderHeaderReportsNoArchitectureFieldsAndFallsBackToMagic() {
        let header = makeHeader(
            magic: "dyld_v1  arm64e",
            mappingOffset: Self.mappingOffsetWithoutArchitecture,
            // Deliberately non-zero: a reader that ignores `mappingOffset`
            // would pick these up and answer x86_64.
            cpuType: CPU_TYPE_X86_64,
            cpuSubType: cpu_subtype_t(CPU_SUBTYPE_X86_64_ALL)
        )

        XCTAssertNil(header.cpu)
        XCTAssertEqual(header._cpuType, .arm64)
        XCTAssertEqual(header._cpuSubType, .arm64(.arm64e))
        XCTAssertEqual(
            header._resolvedCPU?.subtypeRawValue,
            cpu_subtype_t(CPU_SUBTYPE_ARM64E)
        )
    }

    /// If explicit architecture fields are present, they are one source of
    /// truth. An unrecognised subtype must not be replaced with a subtype
    /// inferred from `magic`, as that would create a CPU pair which was never
    /// present in the cache.
    func testArchitectureFieldsAndMagicAreNotMixed() {
        let header = makeHeader(
            magic: "dyld_v1  arm64e",
            mappingOffset: Self.mappingOffsetWithArchitecture,
            cpuType: CPU_TYPE_ARM64,
            cpuSubType: 99
        )

        XCTAssertNotNil(header.cpu)
        XCTAssertEqual(header.cpu?.type, .arm64)
        XCTAssertNil(header.cpu?.subtype)
        XCTAssertEqual(header._resolvedCPU, header.cpu)
        XCTAssertEqual(header._resolvedCPU?.subtypeRawValue, 99)
        XCTAssertEqual(header._cpuType, .arm64)
        XCTAssertNil(header._cpuSubType)
    }

    /// New subtype values must not make an otherwise readable cache fail to
    /// initialize. The raw value remains available while the typed view is
    /// `nil` until MachOKit learns the subtype.
    func testCachesAcceptUnknownSubtypeFromArchitectureFields() throws {
        let header = makeHeader(
            magic: "dyld_v1  arm64e",
            mappingOffset: Self.mappingOffsetWithArchitecture,
            cpuType: CPU_TYPE_ARM64,
            cpuSubType: 99
        )
        var layout = header.layout

        try withUnsafePointer(to: &layout) { pointer in
            let cache = try DyldCacheLoaded(ptr: UnsafeRawPointer(pointer))
            XCTAssertEqual(cache.cpu.type, .arm64)
            XCTAssertEqual(cache.cpu.subtypeRawValue, 99)
            XCTAssertNil(cache.cpu.subtype)
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let data = withUnsafeBytes(of: &layout) { Data($0) }
        try data.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let cache = try DyldCache(url: url)
        XCTAssertEqual(cache.cpu.type, .arm64)
        XCTAssertEqual(cache.cpu.subtypeRawValue, 99)
        XCTAssertNil(cache.cpu.subtype)
    }

    /// Raw subtypes can be carried forward, but an unknown CPU type still
    /// cannot determine the cache architecture.
    func testArchitectureFieldsRejectUnknownCPUType() {
        let header = makeHeader(
            magic: "dyld_v1  arm64e",
            mappingOffset: Self.mappingOffsetWithArchitecture,
            cpuType: 99,
            cpuSubType: 99
        )

        XCTAssertNotNil(header.cpu)
        XCTAssertNil(header.cpu?.type)
        XCTAssertNil(header._resolvedCPU)
    }

    /// Both cache storage paths must retain the complete raw subtype rather
    /// than reconstructing it from the masked typed subtype.
    func testCachesPreserveRawCPUValuesFromArchitectureFields() throws {
        let header = makeHeader(
            magic: "dyld_v1arm64ex1",
            mappingOffset: Self.mappingOffsetWithArchitecture,
            cpuType: CPU_TYPE_ARM64,
            cpuSubType: Self.arm64eX1WithPtrAuthFlag
        )
        var layout = header.layout

        try withUnsafePointer(to: &layout) { pointer in
            let cache = try DyldCacheLoaded(ptr: UnsafeRawPointer(pointer))
            XCTAssertEqual(
                cache.cpu.subtypeRawValue,
                Self.arm64eX1WithPtrAuthFlag
            )
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let data = withUnsafeBytes(of: &layout) { Data($0) }
        try data.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let cache = try DyldCache(url: url)
        XCTAssertEqual(
            cache.cpu.subtypeRawValue,
            Self.arm64eX1WithPtrAuthFlag
        )
    }

    /// The magic fallback has to know the new name too. Unlike every other
    /// architecture it carries no leading padding, because it fills the field.
    func testArm64eX1MagicIsRecognisedWithoutTheHeaderFields() {
        let header = makeHeader(
            magic: "dyld_v1arm64ex1",
            mappingOffset: Self.mappingOffsetWithoutArchitecture
        )

        XCTAssertNil(header.cpu)
        XCTAssertEqual(header._cpuType, .arm64)
        XCTAssertEqual(header._cpuSubType, .arm64(.arm64e_x1))
    }

    /// `magic` is 16 bytes including the terminator, which is why the name had
    /// to move out of it.
    func testArm64eX1MagicFillsTheFieldExactly() {
        XCTAssertEqual("dyld_v1arm64ex1".utf8.count, 15)
        XCTAssertEqual(MemoryLayout.size(ofValue: dyld_cache_header().magic), 16)
    }

    func testSubTypeRawValuesMatchTheCConstants() {
        XCTAssertEqual(CPUARM64SubType.arm64e_x1.rawValue, CPU_SUBTYPE_ARM64E_X1)
        XCTAssertEqual(CPUARM64SubType.arm64_x1.rawValue, CPU_SUBTYPE_ARM64_X1)
        XCTAssertEqual(CPUARM64SubType(rawValue: 12), .arm64e_x1)
        XCTAssertEqual(CPUARM64SubType(rawValue: 3), .arm64_x1)
    }
}
