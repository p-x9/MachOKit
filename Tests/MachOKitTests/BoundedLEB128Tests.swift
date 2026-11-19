//
//  BoundedLEB128Tests.swift
//  MachOKit
//

import XCTest
@_spi(Support) @testable import MachOKit

final class BoundedLEB128Tests: XCTestCase {
    private func uleb(_ bytes: [UInt8], maxSize: Int? = nil) -> (UInt, Int)? {
        bytes.withUnsafeBufferPointer {
            $0.baseAddress!.readULEB128(maxSize: maxSize ?? bytes.count)
        }
    }

    private func sleb(_ bytes: [UInt8], maxSize: Int? = nil) -> (Int, Int)? {
        bytes.withUnsafeBufferPointer {
            $0.baseAddress!.readSLEB128(maxSize: maxSize ?? bytes.count)
        }
    }

    func testULEB128() {
        let vectors: [([UInt8], UInt)] = [
            ([0x00], 0),
            ([0x80, 0x01], 128),
            ([0xE5, 0x8E, 0x26], 624485),
            ([0x85, 0x80, 0x80, 0x80, 0x00], 5),
            ([UInt8](repeating: 0xFF, count: 9) + [0x01], UInt(truncatingIfNeeded: UInt64.max))
        ]
        for (bytes, value) in vectors {
            // trailing bytes must not be consumed
            let actual = uleb(bytes + [0xFF, 0xFF])
            XCTAssertEqual(actual?.0, value, "\(bytes)")
            XCTAssertEqual(actual?.1, bytes.count, "\(bytes)")
        }
    }

    func testULEB128RejectsTruncation() {
        XCTAssertNil(uleb([]))
        XCTAssertNil(uleb([0x80]))
        XCTAssertNil(uleb([0xE5, 0x8E]))
        // The terminating byte exists, but lies outside of the readable range
        XCTAssertNil(uleb([0xE5, 0x8E, 0x26], maxSize: 2))
        XCTAssertNil(uleb([0x01], maxSize: 0))
    }

    func testULEB128RejectsOverflow() {
        // 70 bits of payload
        XCTAssertNil(uleb([UInt8](repeating: 0xFF, count: 10)))
        // bit 64 is set
        XCTAssertNil(uleb([UInt8](repeating: 0x80, count: 9) + [0x02]))
        // more than 10 bytes, even if the value itself is zero
        XCTAssertNil(uleb([UInt8](repeating: 0x80, count: 10) + [0x00]))
    }

    func testSLEB128() {
        let vectors: [([UInt8], Int)] = [
            ([0x02], 2),
            ([0x7F], -1),
            ([0x80, 0x7F], -128),
            ([0xC0, 0xBB, 0x78], -123456),
            ([UInt8](repeating: 0xFF, count: 9) + [0x00], Int(truncatingIfNeeded: Int64.max)),
            ([UInt8](repeating: 0x80, count: 9) + [0x7F], Int(truncatingIfNeeded: Int64.min))
        ]
        for (bytes, value) in vectors {
            let actual = sleb(bytes + [0xFF, 0xFF])
            XCTAssertEqual(actual?.0, value, "\(bytes)")
            XCTAssertEqual(actual?.1, bytes.count, "\(bytes)")
        }
    }

    func testSLEB128RejectsTruncation() {
        XCTAssertNil(sleb([]))
        XCTAssertNil(sleb([0x80]))
        XCTAssertNil(sleb([0x80, 0x7F], maxSize: 1))
        XCTAssertNil(sleb([0x7C], maxSize: 0))
    }

    func testSLEB128RejectsOverflow() {
        // The 10th byte may only repeat the sign bit
        XCTAssertNil(sleb([UInt8](repeating: 0x80, count: 9) + [0x01]))
        XCTAssertNil(sleb([UInt8](repeating: 0x80, count: 9) + [0x7E]))
        XCTAssertNil(sleb([UInt8](repeating: 0xFF, count: 10)))
        XCTAssertNil(sleb([UInt8](repeating: 0x80, count: 10) + [0x00]))
    }

    func testReadStringRequiresTerminatorInRange() {
        let bytes: [UInt8] = [0x61, 0x62, 0x00, 0x63, 0x00]
        bytes.withUnsafeBufferPointer {
            let pointer = $0.baseAddress!
            let string = pointer.readString(maxSize: bytes.count)
            XCTAssertEqual(string?.0, "ab")
            XCTAssertEqual(string?.1, 3)
            XCTAssertEqual(pointer.readString(maxSize: 3)?.0, "ab")
            XCTAssertNil(pointer.readString(maxSize: 2))
            XCTAssertNil(pointer.readString(maxSize: 0))
        }
    }
}

// MARK: - cursor variants
extension BoundedLEB128Tests {
    func testCursorVariantsAdvanceOffsetOnlyOnSuccess() {
        // ULEB128 624485, SLEB128 -128, "ab"
        let bytes: [UInt8] = [0xE5, 0x8E, 0x26, 0x80, 0x7F, 0x61, 0x62, 0x00]
        bytes.withUnsafeBufferPointer {
            let pointer = $0.baseAddress!
            var offset = 0

            XCTAssertEqual(pointer.readULEB128(at: &offset, maxOffset: bytes.count), 624485)
            XCTAssertEqual(offset, 3)
            XCTAssertEqual(pointer.readSLEB128(at: &offset, maxOffset: bytes.count), -128)
            XCTAssertEqual(offset, 5)

            // terminator lies outside of the region
            XCTAssertNil(pointer.readString(at: &offset, maxOffset: bytes.count - 1))
            XCTAssertEqual(offset, 5)

            XCTAssertEqual(pointer.readString(at: &offset, maxOffset: bytes.count), "ab")
            XCTAssertEqual(offset, bytes.count)

            // nothing left to read
            XCTAssertNil(pointer.readULEB128(at: &offset, maxOffset: bytes.count))
            XCTAssertNil(pointer.readSLEB128(at: &offset, maxOffset: bytes.count))
            XCTAssertNil(pointer.readString(at: &offset, maxOffset: bytes.count))
            XCTAssertEqual(offset, bytes.count)
        }
    }
}
