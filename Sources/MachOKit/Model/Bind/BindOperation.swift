//
//  BindOperation.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public enum BindOperation {
    case done
    case set_dylib_ordinal_imm(ordinal: Int)
    case set_dylib_ordinal_uleb(ordinal: Int)
    case set_dylib_special_imm(special: BindSpecial)
    case set_symbol_trailing_flags_imm(flags: Int, symbol: String)
    case set_type_imm(type: BindType)
    case set_addend_sleb(addend: Int)
    case set_segment_and_offset_uleb(segment: Int, offset: Int)
    case add_addr_uleb(offset: Int)
    case do_bind
    case do_bind_add_addr_uleb(offset: Int)
    case do_bind_add_addr_imm_scaled(scale: Int)
    case do_bind_uleb_times_skipping_uleb(count: Int, skip: Int)
    case threaded(BindSubOperation)
}

extension BindOperation {
    public var opcode: BindOpcode {
        switch self {
        case .done: .done
        case .set_dylib_ordinal_imm: .set_dylib_ordinal_imm
        case .set_dylib_ordinal_uleb: .set_dylib_ordinal_uleb
        case .set_dylib_special_imm: .set_dylib_special_imm
        case .set_symbol_trailing_flags_imm: .set_symbol_trailing_flags_imm
        case .set_type_imm: .set_type_imm
        case .set_addend_sleb: .set_addend_sleb
        case .set_segment_and_offset_uleb: .set_segment_and_offset_uleb
        case .add_addr_uleb: .add_addr_uleb
        case .do_bind: .do_bind
        case .do_bind_add_addr_uleb: .do_bind_add_addr_uleb
        case .do_bind_add_addr_imm_scaled: .do_bind_add_addr_imm_scaled
        case .do_bind_uleb_times_skipping_uleb: .do_bind_uleb_times_skipping_uleb
        case .threaded: .threaded
        }
    }
}

extension BindOperation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .done:
            "\(opcode)"
        case .set_dylib_ordinal_imm(let ordinal):
            "\(opcode) ordinal: \(ordinal)"
        case .set_dylib_ordinal_uleb(let ordinal):
            "\(opcode) ordinal: \(ordinal)"
        case .set_dylib_special_imm(let special):
            "\(opcode) special: \(special)"
        case .set_symbol_trailing_flags_imm(let flags, let symbol):
            "\(opcode) flags: \(flags), symbol: \(symbol)"
        case .set_type_imm(let type):
            "\(opcode) type: \(type)"
        case .set_addend_sleb(let addend):
            "\(opcode) addend: \(addend)"
        case .set_segment_and_offset_uleb(let segment, let offset):
            "\(opcode) segment: \(segment), offset: \(offset)"
        case .add_addr_uleb(let offset):
            "\(opcode) offset: \(offset)"
        case .do_bind:
            "\(opcode)"
        case .do_bind_add_addr_uleb(let offset):
            "\(opcode) offset: \(offset)"
        case .do_bind_add_addr_imm_scaled(let scale):
            "\(opcode) scale: \(scale)"
        case .do_bind_uleb_times_skipping_uleb(let count, let skip):
            "\(opcode) count: \(count), skip: \(skip)"
        case .threaded(let bindSubOpcode):
            "\(opcode) subopecode: \(bindSubOpcode)"
        }
    }
}

public enum BindSubOperation {
    case threaded_set_bind_ordinal_table_size_uleb(size: Int)
    case threaded_apply
}

extension BindSubOperation {
    public var opcode: BindSubOpcode {
        switch self {
        case .threaded_set_bind_ordinal_table_size_uleb: .threaded_set_bind_ordinal_table_size_uleb
        case .threaded_apply: .threaded_apply
        }
    }
}

extension BindSubOperation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .threaded_set_bind_ordinal_table_size_uleb(let size):
            "\(opcode) size: \(size)"
        case .threaded_apply:
            "\(opcode)"
        }
    }
}

extension BindOperation {
    internal static func readNext(
        basePointer: UnsafePointer<UInt8>,
        bindSize: Int,
        nextOffset: inout Int
    ) -> BindOperation? {
        guard nextOffset < bindSize else { return nil }

        let val = basePointer.advanced(by: nextOffset).pointee
        nextOffset += MemoryLayout<UInt8>.size

        let imm = Int32(val) & BIND_IMMEDIATE_MASK
        let opcodeRaw = Int32(val) & BIND_OPCODE_MASK
        guard let opcode = BindOpcode(rawValue: opcodeRaw) else {
            return nil
        }

        switch opcode {
        case .done:
            return .done

        case .set_dylib_ordinal_imm:
            return .set_dylib_ordinal_imm(ordinal: Int(imm))

        case .set_dylib_ordinal_uleb:
            let (value, ulebSize) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize
            return .set_dylib_ordinal_uleb(ordinal: value)

        case .set_dylib_special_imm:
            let special = BindSpecial(rawValue: imm)!
            return .set_dylib_special_imm(special: special)

        case .set_symbol_trailing_flags_imm:
            let (string, stringSize) = basePointer
                .advanced(by: nextOffset)
                .readString()
            nextOffset += stringSize
            return .set_symbol_trailing_flags_imm(flags: Int(imm), symbol: string)

        case .set_type_imm:
            let type = BindType(rawValue: imm) ?? .pointer
            return .set_type_imm(type: type)

        case .set_addend_sleb:
            let (value, slebSize) = basePointer
                .advanced(by: nextOffset)
                .readSLEB128()
            nextOffset += slebSize
            return .set_addend_sleb(addend: value)

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

        case .do_bind:
            return .do_bind

        case .do_bind_add_addr_uleb:
            let (value, ulebSize) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize
            return .do_bind_add_addr_uleb(offset: value)

        case .do_bind_add_addr_imm_scaled:
            return .do_bind_add_addr_imm_scaled(scale: Int(imm))

        case .do_bind_uleb_times_skipping_uleb:
            let (count, ulebSize) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize

            let (skip, ulebSize2) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebSize2

            return .do_bind_uleb_times_skipping_uleb(count: count, skip: skip)

        case .threaded:
            let subopcode = BindSubOpcode(rawValue: imm)!
            switch subopcode {
            case .threaded_apply:
                return .threaded(.threaded_apply)
            case .threaded_set_bind_ordinal_table_size_uleb:
                let (size, ulebOff) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebOff
                return .threaded(.threaded_set_bind_ordinal_table_size_uleb(size: Int(size)))
            }
        }
    }
}
