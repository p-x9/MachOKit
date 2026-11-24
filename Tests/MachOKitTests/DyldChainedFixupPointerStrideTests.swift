import XCTest
import MachOKit

/// The `next` field of a chained fixup pointer counts strides, and the stride
/// depends on the pointer format. The expected values are the ones dyld
/// documents next to each `DYLD_CHAINED_PTR_*` constant in
/// `mach-o/fixup-chains.h` and uses when it walks a chain.
final class DyldChainedFixupPointerStrideTests: XCTestCase {
    private static let expectedStrides: [(DyldChainedFixupPointerFormat, Int)] = [
        (.arm64e, 8),
        (._64, 4),
        (._32, 4),
        (._32_cache, 4),
        (._32_firmware, 4),
        (._64_offset, 4),
        (.arm64e_kernel, 4),
        (._64_kernel_cache, 4),
        (.arm64e_userland, 8),
        (.arm64e_firmware, 4),
        (.x86_64_kernel_cache, 1),
        (.arm64e_userland24, 8),
        (.arm64e_shared_cache, 8),
        (.arm64e_segmented, 4),
    ]

    func testStrideOfEveryPointerFormat() {
        for (format, stride) in Self.expectedStrides {
            XCTAssertEqual(format.stride, stride, "\(format)")
        }
    }

    /// Fails when a pointer format is added without an expectation above.
    func testExpectationsCoverEveryPointerFormat() {
        let expected = Set(Self.expectedStrides.map(\.0.rawValue))
        XCTAssertEqual(expected.count, Self.expectedStrides.count)

        let known = (UInt16.min ... 0xFF).filter {
            DyldChainedFixupPointerFormat(rawValue: $0) != nil
        }
        XCTAssertEqual(expected, Set(known))
    }

    func testNextOffsetScalesNextByStride() throws {
        // `next` of every 64-bit pointer layout sits above bit 50; the exact
        // position differs per format, so set it through each format's mask.
        let cases: [(DyldChainedFixupPointerFormat, UInt64, Int)] = [
            // dyld_chained_ptr_arm64e_rebase: next is 11 bits at bit 51
            (.arm64e, 3 << 51, 3),
            (.arm64e_kernel, 3 << 51, 3),
            (.arm64e_userland, 3 << 51, 3),
            (.arm64e_firmware, 3 << 51, 3),
            (.arm64e_userland24, 3 << 51, 3),
            // dyld_chained_ptr_64_rebase: next is 12 bits at bit 51
            (._64, 3 << 51, 3),
            (._64_offset, 3 << 51, 3),
            // dyld_chained_ptr_64_kernel_cache_rebase: next is 12 bits at bit 51
            (._64_kernel_cache, 3 << 51, 3),
            (.x86_64_kernel_cache, 3 << 51, 3),
        ]
        for (format, rawValue, next) in cases {
            let info = try XCTUnwrap(
                DyldChainedFixupPointerInfo(rawValue: rawValue, pointerFormat: format)
            )
            XCTAssertEqual(info.next, next, "\(format)")
            XCTAssertEqual(info.nextOffset, next * format.stride, "\(format)")
        }

        // dyld_chained_ptr_32_rebase: next is 5 bits at bit 26
        let info32 = try XCTUnwrap(
            DyldChainedFixupPointerInfo(rawValue: UInt32(3) << 26, pointerFormat: ._32)
        )
        XCTAssertEqual(info32.next, 3)
        XCTAssertEqual(info32.nextOffset, 12)

        let last = try XCTUnwrap(
            DyldChainedFixupPointerInfo(rawValue: UInt64(0), pointerFormat: .arm64e)
        )
        XCTAssertEqual(last.nextOffset, 0)
    }
}
