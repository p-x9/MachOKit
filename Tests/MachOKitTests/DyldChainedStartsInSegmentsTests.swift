import XCTest
import FileIO
@testable import MachOKit

/// `dyld_chained_starts_in_image.seg_info_offset[i]` is 0 for a segment that
/// has no chained fixups, and dyld skips such a segment
/// (`if ( startsInfo->seg_info_offset[segIndex] == 0 ) continue;`).
/// Reading a `dyld_chained_starts_in_segment` at offset 0 instead
/// reinterprets the image-level header, and `pages(of:)` then trusts a
/// `page_count` made of whatever bytes follow it.
///
/// The payload below mirrors a dylib whose only fixups live in
/// `__DATA_CONST` — a Swift module that declares no class has no `__DATA`
/// segment — so three segments, and only the middle one has starts. Read at
/// offset 0, the first segment's `page_count` lands on the real segment's
/// `page_size`, 0x4000: 16384 phantom pages, read 32 KB past the starts. On a
/// real file that read ran off the end of the mapping, and `swift-section
/// dump` crashed on such dylibs about one run in five.
final class DyldChainedStartsInSegmentsTests: XCTestCase {
    /// Large enough that a phantom 16384-page read stays inside the buffer,
    /// so the regression shows up as wrong output instead of a crash that
    /// depends on what happens to be mapped after the payload.
    private static let payloadSize = 64 * 1024

    private static let startsInImageOffset = 32

    private static func makePayload() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: payloadSize)
        func write<Value: FixedWidthInteger>(_ value: Value, at offset: Int) {
            withUnsafeBytes(of: value.littleEndian) { source in
                for (index, byte) in source.enumerated() {
                    bytes[offset + index] = byte
                }
            }
        }

        // dyld_chained_fixups_header
        write(UInt32(0), at: 0) // fixups_version
        write(UInt32(startsInImageOffset), at: 4) // starts_offset
        write(UInt32(payloadSize - 8), at: 8) // imports_offset
        write(UInt32(payloadSize - 8), at: 12) // symbols_offset
        write(UInt32(0), at: 16) // imports_count
        write(UInt32(1), at: 20) // imports_format: DYLD_CHAINED_IMPORT
        write(UInt32(0), at: 24) // symbols_format: uncompressed

        // dyld_chained_starts_in_image: __TEXT, __DATA_CONST, __LINKEDIT
        write(UInt32(3), at: startsInImageOffset) // seg_count
        write(UInt32(0), at: startsInImageOffset + 4) // __TEXT: no fixups
        write(UInt32(16), at: startsInImageOffset + 8) // __DATA_CONST
        write(UInt32(0), at: startsInImageOffset + 12) // __LINKEDIT: no fixups

        // dyld_chained_starts_in_segment of __DATA_CONST
        let segmentStartsOffset = startsInImageOffset + 16
        write(UInt32(24), at: segmentStartsOffset) // size
        write(UInt16(0x4000), at: segmentStartsOffset + 4) // page_size
        write(UInt16(6), at: segmentStartsOffset + 6) // pointer_format: DYLD_CHAINED_PTR_64_OFFSET
        write(UInt64(0x4000), at: segmentStartsOffset + 8) // segment_offset
        write(UInt32(0), at: segmentStartsOffset + 16) // max_valid_pointer
        write(UInt16(1), at: segmentStartsOffset + 20) // page_count
        write(UInt16(0xFFFF), at: segmentStartsOffset + 22) // page_start[0]: DYLD_CHAINED_PTR_START_NONE

        return bytes
    }

    private func assertOnlyTheSegmentWithFixupsHasPages(
        _ startsInSegments: [DyldChainedStartsInSegment],
        pages: (DyldChainedStartsInSegment) -> [DyldChainedPage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(startsInSegments.map(\.segmentIndex), [0, 1, 2], "one entry per segment, in segment order", file: file, line: line)
        XCTAssertEqual(startsInSegments.map { pages($0).count }, [0, 1, 0], file: file, line: line)
        XCTAssertEqual(startsInSegments[1].layout.page_size, 0x4000, file: file, line: line)
        XCTAssertEqual(startsInSegments[1].layout.segment_offset, 0x4000, file: file, line: line)
    }

    func testSegmentsWithoutFixupsHaveNoPagesInAnImage() {
        let payload = Self.makePayload()
        payload.withUnsafeBufferPointer { buffer in
            let chainedFixups = MachOImage.DyldChainedFixups(
                basePointer: buffer.baseAddress!,
                dyldChainedFixupsSize: buffer.count
            )
            let startsInSegments = chainedFixups.startsInSegments(of: chainedFixups.startsInImage)
            assertOnlyTheSegmentWithFixupsHasPages(startsInSegments, pages: { chainedFixups.pages(of: $0) })
        }
    }

    func testSegmentsWithoutFixupsHaveNoPagesInAFile() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DyldChainedStartsInSegmentsTests-\(UUID().uuidString)")
        try Data(Self.makePayload()).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let file = try MachOFile.File.open(url: url, isWritable: false)
        let chainedFixups = MachOFile.DyldChainedFixups(
            fileSlice: try file.fileSlice(offset: 0, length: Self.payloadSize),
            isSwapped: false
        )
        let startsInSegments = chainedFixups.startsInSegments(of: chainedFixups.startsInImage)
        assertOnlyTheSegmentWithFixupsHasPages(startsInSegments, pages: { chainedFixups.pages(of: $0) })
    }
}
