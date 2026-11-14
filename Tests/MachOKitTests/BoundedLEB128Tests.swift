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
            ([UInt8](repeating: 0xFF, count: 9) + [0x01], UInt(UInt64.max))
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
            ([UInt8](repeating: 0xFF, count: 9) + [0x00], Int(Int64.max)),
            ([UInt8](repeating: 0x80, count: 9) + [0x7F], Int(Int64.min))
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

// MARK: - opcode streams
extension BoundedLEB128Tests {
    private func bind(_ bytes: [UInt8], size: Int? = nil) -> BindOperation? {
        var nextOffset = 0
        return bytes.withUnsafeBufferPointer {
            BindOperation.readNext(
                basePointer: $0.baseAddress!,
                bindSize: size ?? bytes.count,
                nextOffset: &nextOffset
            )
        }
    }

    private func rebase(_ bytes: [UInt8], size: Int? = nil) -> RebaseOperation? {
        var nextOffset = 0
        var done = false
        return bytes.withUnsafeBufferPointer {
            RebaseOperation.readNext(
                basePointer: $0.baseAddress!,
                rebaseSize: size ?? bytes.count,
                nextOffset: &nextOffset,
                done: &done
            )
        }
    }

    private func functionStart(_ bytes: [UInt8], size: Int? = nil) -> FunctionStart? {
        var nextOffset = 0
        return bytes.withUnsafeBufferPointer {
            FunctionStart.readNext(
                basePointer: $0.baseAddress!,
                functionStartsSize: size ?? bytes.count,
                lastFunctionOffset: 0x1000,
                nextOffset: &nextOffset
            )
        }
    }

    func testBindOperationStaysInsideOpcodeStream() {
        let ordinalULEB = UInt8(BindOpcode.set_dylib_ordinal_uleb.rawValue)
        let symbol = UInt8(BindOpcode.set_symbol_trailing_flags_imm.rawValue)
        let addendSLEB = UInt8(BindOpcode.set_addend_sleb.rawValue)
        let timesSkipping = UInt8(BindOpcode.do_bind_uleb_times_skipping_uleb.rawValue)

        XCTAssertNotNil(bind([ordinalULEB, 0x80, 0x01]))
        XCTAssertNotNil(bind([symbol, 0x5F, 0x61, 0x00]))
        XCTAssertNotNil(bind([addendSLEB, 0x7C]))

        XCTAssertNil(bind([ordinalULEB]))
        XCTAssertNil(bind([ordinalULEB, 0x80]))
        XCTAssertNil(bind([ordinalULEB, 0x80, 0x01], size: 2))
        XCTAssertNil(bind([ordinalULEB] + [UInt8](repeating: 0xFF, count: 10)))
        XCTAssertNil(bind([symbol, 0x5F, 0x61]))
        XCTAssertNil(bind([symbol, 0x5F, 0x61, 0x00], size: 3))
        XCTAssertNil(bind([addendSLEB, 0x80]))
        XCTAssertNil(bind([timesSkipping, 0x01]))
    }

    func testRebaseOperationStaysInsideOpcodeStream() {
        let addAddr = UInt8(RebaseOpcode.add_addr_uleb.rawValue)
        let timesSkipping = UInt8(RebaseOpcode.do_rebase_uleb_times_skipping_uleb.rawValue)

        XCTAssertNotNil(rebase([addAddr, 0x80, 0x01]))
        XCTAssertNotNil(rebase([timesSkipping, 0x02, 0x08]))

        XCTAssertNil(rebase([addAddr]))
        XCTAssertNil(rebase([addAddr, 0x80]))
        XCTAssertNil(rebase([addAddr, 0x80, 0x01], size: 2))
        XCTAssertNil(rebase([addAddr] + [UInt8](repeating: 0xFF, count: 10)))
        XCTAssertNil(rebase([timesSkipping, 0x02]))
    }

    func testFunctionStartStaysInsideData() {
        XCTAssertEqual(functionStart([0x80, 0x01])?.offset, 0x1080)
        XCTAssertNil(functionStart([0x80]))
        XCTAssertNil(functionStart([0x80, 0x01], size: 1))
        XCTAssertNil(functionStart([UInt8](repeating: 0xFF, count: 10)))
    }
}
