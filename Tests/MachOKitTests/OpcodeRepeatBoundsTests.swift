//
//  OpcodeRepeatBoundsTests.swift
//  MachOKit
//

import XCTest
@_spi(Support) @testable import MachOKit

final class OpcodeRepeatBoundsTests: XCTestCase {
    private let segmentSizes: [UInt] = [0x4000, 0x100]

    private func bindOffsets(
        _ operations: [BindOperation],
        is64Bit: Bool = true
    ) -> [UInt] {
        operations
            .bindings(is64Bit: is64Bit, segmentSizes: segmentSizes)
            .map(\.segmentOffset)
    }

    private func rebaseOffsets(
        _ operations: [RebaseOperation],
        is64Bit: Bool = true
    ) -> [UInt] {
        operations
            .rebases(is64Bit: is64Bit, segmentSizes: segmentSizes)
            .map(\.segmentOffset)
    }
}

// MARK: - bind
extension OpcodeRepeatBoundsTests {
    func testBindTimesSkippingWellFormed() {
        XCTAssertEqual(
            bindOffsets([
                .set_segment_and_offset_uleb(segment: 1, offset: 0x10),
                .do_bind_uleb_times_skipping_uleb(count: 3, skip: 8),
                .do_bind
            ]),
            [0x10, 0x20, 0x30, 0x40]
        )
        XCTAssertEqual(
            bindOffsets([
                .set_segment_and_offset_uleb(segment: 1, offset: 0),
                .do_bind_uleb_times_skipping_uleb(count: 2, skip: 4)
            ], is64Bit: false),
            [0, 8]
        )
    }

    func testBindTimesSkippingStopsAtSegmentEnd() {
        // 0x100 / 8 pointers fit in segment 1
        XCTAssertEqual(
            bindOffsets([
                .set_segment_and_offset_uleb(segment: 1, offset: 0),
                .do_bind_uleb_times_skipping_uleb(count: .max, skip: 0)
            ]),
            Array(stride(from: 0, to: 0x100, by: 8))
        )
        // last pointer would straddle the end of the segment
        XCTAssertEqual(
            bindOffsets([
                .set_segment_and_offset_uleb(segment: 1, offset: 0xF9),
                .do_bind_uleb_times_skipping_uleb(count: .max, skip: 0)
            ]),
            []
        )
        // unknown segment
        XCTAssertEqual(
            bindOffsets([
                .set_segment_and_offset_uleb(segment: 2, offset: 0),
                .do_bind_uleb_times_skipping_uleb(count: .max, skip: 0)
            ]),
            []
        )
    }

    func testBindTimesSkippingDoesNotTrapOnOverflow() {
        // skip + ptrSize overflows
        XCTAssertEqual(
            bindOffsets([
                .set_segment_and_offset_uleb(segment: 0, offset: 0x10),
                .do_bind_uleb_times_skipping_uleb(count: .max, skip: .max)
            ]),
            [0x10]
        )
        // skip + ptrSize wraps to 0, which would repeat the same address forever
        XCTAssertEqual(
            bindOffsets([
                .set_segment_and_offset_uleb(segment: 0, offset: 0x10),
                .do_bind_uleb_times_skipping_uleb(count: .max, skip: .max - 7)
            ]),
            [0x10]
        )
    }
}

// MARK: - rebase
extension OpcodeRepeatBoundsTests {
    func testRebaseTimesWellFormed() {
        XCTAssertEqual(
            rebaseOffsets([
                .set_segment_and_offset_uleb(segment: 1, offset: 0x10),
                .do_rebase_imm_times(count: 2),
                .do_rebase_uleb_times(count: 2),
                .do_rebase_uleb_times_skipping_uleb(count: 2, skip: 8),
                .do_rebase_add_addr_uleb(offset: 8),
                .do_rebase_imm_times(count: 1)
            ]),
            [0x10, 0x18, 0x20, 0x28, 0x30, 0x40, 0x50, 0x60]
        )
    }

    func testRebaseTimesStopsAtSegmentEnd() {
        let expected = Array(stride(from: UInt(0), to: 0x100, by: 8))
        XCTAssertEqual(
            rebaseOffsets([
                .set_segment_and_offset_uleb(segment: 1, offset: 0),
                .do_rebase_uleb_times(count: .max)
            ]),
            expected
        )
        XCTAssertEqual(
            rebaseOffsets([
                .set_segment_and_offset_uleb(segment: 1, offset: 0),
                .do_rebase_uleb_times_skipping_uleb(count: .max, skip: 0)
            ]),
            expected
        )
        XCTAssertEqual(
            rebaseOffsets([
                .set_segment_and_offset_uleb(segment: 1, offset: 0xF8),
                .do_rebase_imm_times(count: 15)
            ]),
            [0xF8]
        )
        XCTAssertEqual(
            rebaseOffsets([
                .set_segment_and_offset_uleb(segment: 2, offset: 0),
                .do_rebase_uleb_times(count: .max)
            ]),
            []
        )
    }

    func testRebaseTimesDoesNotTrapOnOverflow() {
        XCTAssertEqual(
            rebaseOffsets([
                .set_segment_and_offset_uleb(segment: 0, offset: 0x10),
                .do_rebase_uleb_times_skipping_uleb(count: .max, skip: .max)
            ]),
            [0x10]
        )
        XCTAssertEqual(
            rebaseOffsets([
                .set_segment_and_offset_uleb(segment: 0, offset: 0x10),
                .do_rebase_uleb_times_skipping_uleb(count: .max, skip: .max - 7)
            ]),
            [0x10]
        )
    }
}
