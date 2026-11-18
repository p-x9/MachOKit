import XCTest
import FileIO
@testable import MachOKit

final class DyldChainedMultiStartTests: XCTestCase {
    private let payloadOffset = 0x3000
    private let segmentStartsOffset = 36

    func testMultipleChainsKeepTheirPageOffsets() throws {
        try checkFixture(fixture()) { fixups, segment, machO in
            XCTAssertEqual(fixups.pages(of: segment).map(\.offset), [0x8002, 0x20])
            let pointers = fixups.pointers(of: segment, in: machO)
            XCTAssertEqual(pointers.map(\.offset), [0x1010, 0x1020, 0x1040, 0x2020])
            XCTAssertEqual(pointers.compactMap { $0.fixupInfo.rebase?.target }, [0x1100, 0x1200, 0x1300, 0x1400])
            for offset in [0x1010, 0x1020, 0x1040, 0x2020] {
                XCTAssertEqual(fixups.pointer(for: UInt64(offset), in: machO)?.offset, offset)
            }
            XCTAssertNil(fixups.pointer(for: 0x1030, in: machO))
        }
    }

    func testOverflowIndexOutsideEntriesIsRejected() throws {
        try assertMultiStartUnavailable(fixture(firstPage: 0x8004))
    }

    func testOverflowIndexInsidePageTableIsRejected() throws {
        try assertMultiStartUnavailable(fixture(firstPage: 0x8001))
    }

    func testMissingLastFlagIsRejected() throws {
        try assertMultiStartUnavailable(fixture(lastEntry: 0x40))
    }

    func testOverflowStartOutsidePageIsRejected() throws {
        try assertMultiStartUnavailable(fixture(lastEntry: 0x9000))
    }

    func testTruncatedSegmentStartsAreRejected() throws {
        var data = fixture()
        // Declare one extra entry beyond the LC_DYLD_CHAINED_FIXUPS payload.
        store(UInt32(32), in: &data, at: payloadOffset + segmentStartsOffset)
        try checkFixture(data) { fixups, segment, machO in
            XCTAssertTrue(fixups.pages(of: segment).isEmpty)
            XCTAssertTrue(fixups.pointers(of: segment, in: machO).isEmpty)
            XCTAssertNil(fixups.pointer(for: 0x1010, in: machO))
        }
    }

    func testChainCannotContinueIntoTheFollowingPage() throws {
        var data = fixture(firstPage: 0x0FFC)
        store(UInt32(1) << 26 | 0x1500, in: &data, at: 0x1FFC)
        try checkFixture(data) { fixups, segment, machO in
            XCTAssertEqual(fixups.pointers(of: segment, in: machO).map(\.offset), [0x1FFC, 0x2020])
            XCTAssertNil(fixups.pointer(for: 0x2000, in: machO))
        }
    }

    func testTruncatedPageStopsBeforeReadingPastTheFile() throws {
        var data = fixture()
        // Point the page buffer near EOF, where a complete pointer cannot fit.
        store(UInt64(data.count - 2), in: &data, at: payloadOffset + segmentStartsOffset + 8)
        try checkFixture(data) { fixups, segment, machO in
            XCTAssertTrue(fixups.pointers(of: segment, in: machO).isEmpty)
            XCTAssertNil(fixups.pointer(for: segment.segment_offset + 0x10, in: machO))
        }
    }

    func testUnrepresentableSegmentOffsetIsRejected() throws {
        var data = fixture()
        store(UInt64.max - 0x10, in: &data, at: payloadOffset + segmentStartsOffset + 8)
        try checkFixture(data) { fixups, segment, machO in
            XCTAssertTrue(fixups.pointers(of: segment, in: machO).isEmpty)
            XCTAssertNil(fixups.pointer(for: UInt64.max, in: machO))
        }
    }

    func testSwappedOverflowEntries() throws {
        let data = fixture(swappedMetadata: true)
        try checkFixture(data, swappedMetadata: true) { fixups, segment, machO in
            XCTAssertEqual(fixups.pages(of: segment).map(\.offset), [0x8002, 0x20])
            XCTAssertEqual(fixups.pointers(of: segment, in: machO).map(\.offset), [0x1010, 0x1020, 0x1040, 0x2020])
            XCTAssertEqual(fixups.pointer(for: 0x1040, in: machO)?.offset, 0x1040)
        }
    }

    private func assertMultiStartUnavailable(_ data: Data) throws {
        try checkFixture(data) { fixups, segment, machO in
            // The independent single-start page remains available.
            XCTAssertEqual(fixups.pointers(of: segment, in: machO).map(\.offset), [0x2020])
            XCTAssertNil(fixups.pointer(for: 0x1010, in: machO))
            XCTAssertNil(fixups.pointer(for: 0x1040, in: machO))
        }
    }

    private func checkFixture(
        _ data: Data,
        swappedMetadata: Bool = false,
        check: (MachOFile.DyldChainedFixups, DyldChainedStartsInSegment, MachOFile) throws -> Void
    ) throws {
        let machO = try MachOFile(data: data)
        let fixups: MachOFile.DyldChainedFixups
        if swappedMetadata {
            // Swap metadata independently to exercise the reader's endian path.
            fixups = .init(
                fileSlice: try machO.fileHandle.fileSlice(offset: payloadOffset, length: data.count - payloadOffset),
                isSwapped: true
            )
        } else {
            fixups = try XCTUnwrap(machO.dyldChainedFixups)
        }
        let segment = try XCTUnwrap(fixups.startsInSegments(of: fixups.startsInImage).first)
        try check(fixups, segment, machO)
    }

    private func fixture(
        firstPage: UInt16 = 0x8002,
        lastEntry: UInt16 = 0x8040,
        swappedMetadata: Bool = false
    ) -> Data {
        let payloadSize = segmentStartsOffset + 30
        var data = Data(count: payloadOffset + payloadSize)
        var header = mach_header()
        header.magic = UInt32(MH_MAGIC)
        header.cputype = CPU_TYPE_ARM
        header.filetype = UInt32(MH_OBJECT)
        header.ncmds = 1
        header.sizeofcmds = UInt32(MemoryLayout<linkedit_data_command>.size)
        store(header, in: &data, at: 0)

        var command = linkedit_data_command()
        command.cmd = UInt32(LC_DYLD_CHAINED_FIXUPS)
        command.cmdsize = header.sizeofcmds
        command.dataoff = UInt32(payloadOffset)
        command.datasize = UInt32(payloadSize)
        store(command, in: &data, at: MemoryLayout<mach_header>.size)

        var fixups = DyldChainedFixupsHeader.Layout()
        fixups.starts_offset = 28
        let wrappedHeader = DyldChainedFixupsHeader(layout: fixups)
        store(swappedMetadata ? wrappedHeader.swapped.layout : fixups, in: &data, at: payloadOffset)
        store(swappedMetadata ? UInt32(1).byteSwapped : UInt32(1), in: &data, at: payloadOffset + 28)
        store(swappedMetadata ? UInt32(8).byteSwapped : UInt32(8), in: &data, at: payloadOffset + 32)

        var layout = DyldChainedStartsInSegment.Layout()
        layout.size = 30
        layout.page_size = 0x1000
        layout.pointer_format = UInt16(DYLD_CHAINED_PTR_32)
        layout.segment_offset = 0x1000
        layout.page_count = 2
        layout.page_start = firstPage
        let segment = DyldChainedStartsInSegment(layout: layout, offset: segmentStartsOffset, segmentIndex: 0)
        store(swappedMetadata ? segment.swapped.layout : layout, in: &data, at: payloadOffset + segmentStartsOffset)
        for (index, value) in [UInt16(0x20), 0x10, lastEntry].enumerated() {
            store(swappedMetadata ? value.byteSwapped : value, in: &data, at: payloadOffset + segmentStartsOffset + 24 + index * 2)
        }

        // Two chains on page 0, one chain on page 1. The first chain has two pointers.
        store(UInt32(4) << 26 | 0x1100, in: &data, at: 0x1010)
        store(UInt32(0x1200), in: &data, at: 0x1020)
        store(UInt32(0x1300), in: &data, at: 0x1040)
        store(UInt32(0x1400), in: &data, at: 0x2020)
        return data
    }

    private func store<T>(_ value: T, in data: inout Data, at offset: Int) {
        withUnsafeBytes(of: value) {
            data.replaceSubrange(offset ..< offset + $0.count, with: $0)
        }
    }
}
