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

    func testULEB128MatchesUnboundedReader() {
        let vectors: [[UInt8]] = [
            [0x00],
            [0x7F],
            [0x80, 0x01],
            [0xE5, 0x8E, 0x26], // 624485
            [0x85, 0x80, 0x80, 0x80, 0x00], // padded 5
            [0xFF, 0xFF, 0xFF, 0xFF, 0x0F], // UInt32.max
            [UInt8](repeating: 0xFF, count: 9) + [0x01] // UInt64.max
        ]
        for bytes in vectors {
            let expected = bytes.withUnsafeBufferPointer {
                $0.baseAddress!.readULEB128()
            }
            // trailing bytes must not be consumed
            let actual = uleb(bytes + [0xFF, 0xFF])
            XCTAssertEqual(actual?.0, expected.0, "\(bytes)")
            XCTAssertEqual(actual?.1, expected.1, "\(bytes)")
            XCTAssertEqual(actual?.1, bytes.count, "\(bytes)")
        }
        XCTAssertEqual(uleb([0xE5, 0x8E, 0x26])?.0, 624485)
        XCTAssertEqual(
            uleb([UInt8](repeating: 0xFF, count: 9) + [0x01])?.0,
            UInt(UInt64.max)
        )
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

    func testSLEB128MatchesUnboundedReader() {
        let vectors: [([UInt8], Int)] = [
            ([0x00], 0),
            ([0x02], 2),
            ([0x7C], -4),
            ([0x7F], -1),
            ([0xFF, 0x00], 127),
            ([0x80, 0x7F], -128),
            ([0xC0, 0xBB, 0x78], -123456),
            ([UInt8](repeating: 0x80, count: 8) + [0x40], -(1 << 62)),
            ([UInt8](repeating: 0xFF, count: 9) + [0x7F], -1),
            ([UInt8](repeating: 0xFF, count: 9) + [0x00], Int(Int64.max)),
            ([UInt8](repeating: 0x80, count: 9) + [0x7F], Int(Int64.min))
        ]
        for (bytes, value) in vectors {
            let expected = bytes.withUnsafeBufferPointer {
                $0.baseAddress!.readSLEB128()
            }
            let actual = sleb(bytes + [0xFF, 0xFF])
            XCTAssertEqual(actual?.0, value, "\(bytes)")
            XCTAssertEqual(actual?.1, bytes.count, "\(bytes)")
            XCTAssertEqual(actual?.0, expected.0, "\(bytes)")
            XCTAssertEqual(actual?.1, expected.1, "\(bytes)")
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
    private func bind(_ bytes: [UInt8], size: Int? = nil) -> (BindOperation?, Int) {
        var nextOffset = 0
        let operation = bytes.withUnsafeBufferPointer {
            BindOperation.readNext(
                basePointer: $0.baseAddress!,
                bindSize: size ?? bytes.count,
                nextOffset: &nextOffset
            )
        }
        return (operation, nextOffset)
    }

    private func rebase(_ bytes: [UInt8], size: Int? = nil) -> (RebaseOperation?, Int) {
        var nextOffset = 0
        var done = false
        let operation = bytes.withUnsafeBufferPointer {
            RebaseOperation.readNext(
                basePointer: $0.baseAddress!,
                rebaseSize: size ?? bytes.count,
                nextOffset: &nextOffset,
                done: &done
            )
        }
        return (operation, nextOffset)
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

        // valid
        if case let (.set_dylib_ordinal_uleb(ordinal), size) = bind([ordinalULEB, 0x80, 0x01]) {
            XCTAssertEqual(ordinal, 128)
            XCTAssertEqual(size, 3)
        } else { XCTFail("set_dylib_ordinal_uleb") }

        if case let (.set_symbol_trailing_flags_imm(flags, name), size) = bind([symbol | 1, 0x5F, 0x61, 0x00]) {
            XCTAssertEqual(flags, 1)
            XCTAssertEqual(name, "_a")
            XCTAssertEqual(size, 4)
        } else { XCTFail("set_symbol_trailing_flags_imm") }

        if case let (.set_addend_sleb(addend), size) = bind([addendSLEB, 0x7C]) {
            XCTAssertEqual(addend, -4)
            XCTAssertEqual(size, 2)
        } else { XCTFail("set_addend_sleb") }

        // malformed
        XCTAssertNil(bind([ordinalULEB]).0)
        XCTAssertNil(bind([ordinalULEB, 0x80]).0)
        XCTAssertNil(bind([ordinalULEB, 0x80, 0x01], size: 2).0)
        XCTAssertNil(bind([ordinalULEB] + [UInt8](repeating: 0xFF, count: 10)).0)
        XCTAssertNil(bind([symbol, 0x5F, 0x61]).0)
        XCTAssertNil(bind([symbol, 0x5F, 0x61, 0x00], size: 3).0)
        XCTAssertNil(bind([addendSLEB, 0x80]).0)
        XCTAssertNil(bind([timesSkipping, 0x01]).0)
    }

    func testRebaseOperationStaysInsideOpcodeStream() {
        let addAddr = UInt8(RebaseOpcode.add_addr_uleb.rawValue)
        let timesSkipping = UInt8(RebaseOpcode.do_rebase_uleb_times_skipping_uleb.rawValue)

        // valid
        if case let (.add_addr_uleb(offset), size) = rebase([addAddr, 0x80, 0x01]) {
            XCTAssertEqual(offset, 128)
            XCTAssertEqual(size, 3)
        } else { XCTFail("add_addr_uleb") }

        if case let (.do_rebase_uleb_times_skipping_uleb(count, skip), size) = rebase([timesSkipping, 0x02, 0x08]) {
            XCTAssertEqual(count, 2)
            XCTAssertEqual(skip, 8)
            XCTAssertEqual(size, 3)
        } else { XCTFail("do_rebase_uleb_times_skipping_uleb") }

        // malformed
        XCTAssertNil(rebase([addAddr]).0)
        XCTAssertNil(rebase([addAddr, 0x80]).0)
        XCTAssertNil(rebase([addAddr, 0x80, 0x01], size: 2).0)
        XCTAssertNil(rebase([addAddr] + [UInt8](repeating: 0xFF, count: 10)).0)
        XCTAssertNil(rebase([timesSkipping, 0x02]).0)
    }

    func testFunctionStartStaysInsideData() {
        XCTAssertEqual(functionStart([0x80, 0x01])?.offset, 0x1080)
        XCTAssertNil(functionStart([0x80]))
        XCTAssertNil(functionStart([0x80, 0x01], size: 1))
        XCTAssertNil(functionStart([UInt8](repeating: 0xFF, count: 10)))
    }
}
