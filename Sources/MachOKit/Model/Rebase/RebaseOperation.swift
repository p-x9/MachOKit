//
//  RebaseOperation.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public enum RebaseOperation {
    /// REBASE_OPCODE_DONE
    case done
    /// REBASE_OPCODE_SET_TYPE_IMM
    case set_type_imm(RebaseType)
    /// REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB
    case set_segment_and_offset_uleb(segment: Int, offset: UInt)
    /// REBASE_OPCODE_ADD_ADDR_ULEB
    case add_addr_uleb(offset: UInt)
    /// REBASE_OPCODE_ADD_ADDR_IMM_SCALED
    case add_addr_imm_scaled(scale: UInt)
    /// REBASE_OPCODE_DO_REBASE_IMM_TIMES
    case do_rebase_imm_times(count: UInt)
    /// REBASE_OPCODE_DO_REBASE_ULEB_TIMES
    case do_rebase_uleb_times(count: UInt)
    /// REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB
    case do_rebase_add_addr_uleb(offset: UInt)
    /// REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB
    case do_rebase_uleb_times_skipping_uleb(count: UInt, skip: UInt)
}

extension RebaseOperation {
    public var opcode: RebaseOpcode {
        switch self {
        case .done: .done
        case .set_type_imm: .set_type_imm
        case .set_segment_and_offset_uleb: .set_segment_and_offset_uleb
        case .add_addr_uleb: .add_addr_uleb
        case .add_addr_imm_scaled: .add_addr_imm_scaled
        case .do_rebase_imm_times: .do_rebase_imm_times
        case .do_rebase_uleb_times: .do_rebase_uleb_times
        case .do_rebase_add_addr_uleb: .do_rebase_add_addr_uleb
        case .do_rebase_uleb_times_skipping_uleb: .do_rebase_uleb_times_skipping_uleb
        }
    }
}

extension RebaseOperation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .done:
            opcode.description
        case .set_type_imm(let rebaseType):
            "\(opcode) \(rebaseType)"
        case .set_segment_and_offset_uleb(let segment, let offset):
            "\(opcode) segment: \(segment), offset: \(offset)"
        case .add_addr_uleb(let offset):
            "\(opcode) offset: \(offset)"
        case .add_addr_imm_scaled(let scale):
            "\(opcode) scale: \(scale)"
        case .do_rebase_imm_times(let count):
            "\(opcode) cout: \(count)"
        case .do_rebase_uleb_times(let count):
            "\(opcode) count: \(count)"
        case .do_rebase_add_addr_uleb(let offset):
            "\(opcode) offset: \(offset)"
        case .do_rebase_uleb_times_skipping_uleb(let count, let skip):
            "\(opcode) count: \(count), skip: \(skip)"
        }
    }
}

extension RebaseOperation {
    internal static func readNext(
        basePointer: UnsafePointer<UInt8>,
        rebaseSize: Int,
        nextOffset: inout Int,
        done: inout Bool
    ) -> RebaseOperation? {
        guard !done, nextOffset < rebaseSize else { return nil }

        let val = basePointer.advanced(by: nextOffset).pointee
        nextOffset += MemoryLayout<UInt8>.size

        let imm = Int32(val) & REBASE_IMMEDIATE_MASK
        let opcodeRaw = Int32(val) & REBASE_OPCODE_MASK
        guard let opcode = RebaseOpcode(rawValue: opcodeRaw) else {
            return nil
        }

        switch opcode {
        case .done:
            done = true
            return .done

        case .set_type_imm:
            let type = RebaseType(rawValue: imm)
            return .set_type_imm(type ?? .pointer)

        case .set_segment_and_offset_uleb:
            let (value, ulebSize) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize
            return .set_segment_and_offset_uleb(segment: Int(imm), offset: value)

        case .add_addr_uleb:
            let (value, ulebSize) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize
            return .add_addr_uleb(offset: value)

        case .add_addr_imm_scaled:
            return .add_addr_imm_scaled(scale: UInt(imm))

        case .do_rebase_imm_times:
            return .do_rebase_imm_times(count: UInt(imm))

        case .do_rebase_uleb_times:
            let (value, ulebSize) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize
            return .do_rebase_uleb_times(count: value)

        case .do_rebase_add_addr_uleb:
            let (value, ulebSize) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize
            return .do_rebase_add_addr_uleb(offset: value)

        case .do_rebase_uleb_times_skipping_uleb:
            let (value1, ulebSize1) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize1

            let (value2, ulebSize2) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize2
            return .do_rebase_uleb_times_skipping_uleb(count: value1, skip: value2)
        }
    }
}
