//
//  BindOpcode.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public enum BindOpcode {
    case done
    case set_dylib_ordinal_imm
    case set_dylib_ordinal_uleb
    case set_dylib_special_imm
    case set_symbol_trailing_flags_imm
    case set_type_imm
    case set_addend_sleb
    case set_segment_and_offset_uleb
    case add_addr_uleb
    case do_bind
    case do_bind_add_addr_uleb
    case do_bind_add_addr_imm_scaled
    case do_bind_uleb_times_skipping_uleb
    case threaded
}

extension BindOpcode: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case BIND_OPCODE_DONE: self = .done
        case BIND_OPCODE_SET_DYLIB_ORDINAL_IMM: self = .set_dylib_ordinal_imm
        case BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB: self = .set_dylib_ordinal_uleb
        case BIND_OPCODE_SET_DYLIB_SPECIAL_IMM: self = .set_dylib_special_imm
        case BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM: self = .set_symbol_trailing_flags_imm
        case BIND_OPCODE_SET_TYPE_IMM: self = .set_type_imm
        case BIND_OPCODE_SET_ADDEND_SLEB: self = .set_addend_sleb
        case BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB: self = .set_segment_and_offset_uleb
        case BIND_OPCODE_ADD_ADDR_ULEB: self = .add_addr_uleb
        case BIND_OPCODE_DO_BIND: self = .do_bind
        case BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB: self = .do_bind_add_addr_uleb
        case BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED: self = .do_bind_add_addr_imm_scaled
        case BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB: self = .do_bind_uleb_times_skipping_uleb
        case BIND_OPCODE_THREADED: self = .threaded
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .done: BIND_OPCODE_DONE
        case .set_dylib_ordinal_imm: BIND_OPCODE_SET_DYLIB_ORDINAL_IMM
        case .set_dylib_ordinal_uleb: BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB
        case .set_dylib_special_imm: BIND_OPCODE_SET_DYLIB_SPECIAL_IMM
        case .set_symbol_trailing_flags_imm: BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM
        case .set_type_imm: BIND_OPCODE_SET_TYPE_IMM
        case .set_addend_sleb: BIND_OPCODE_SET_ADDEND_SLEB
        case .set_segment_and_offset_uleb: BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB
        case .add_addr_uleb: BIND_OPCODE_ADD_ADDR_ULEB
        case .do_bind: BIND_OPCODE_DO_BIND
        case .do_bind_add_addr_uleb: BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB
        case .do_bind_add_addr_imm_scaled: BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED
        case .do_bind_uleb_times_skipping_uleb: BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB
        case .threaded: BIND_OPCODE_THREADED
        }
    }
}

extension BindOpcode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .done: "BIND_OPCODE_DONE"
        case .set_dylib_ordinal_imm: "BIND_OPCODE_SET_DYLIB_ORDINAL_IMM"
        case .set_dylib_ordinal_uleb: "BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB"
        case .set_dylib_special_imm: "BIND_OPCODE_SET_DYLIB_SPECIAL_IMM"
        case .set_symbol_trailing_flags_imm: "BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM"
        case .set_type_imm: "BIND_OPCODE_SET_TYPE_IMM"
        case .set_addend_sleb: "BIND_OPCODE_SET_ADDEND_SLEB"
        case .set_segment_and_offset_uleb: "BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB"
        case .add_addr_uleb: "BIND_OPCODE_ADD_ADDR_ULEB"
        case .do_bind: "BIND_OPCODE_DO_BIND"
        case .do_bind_add_addr_uleb: "BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB"
        case .do_bind_add_addr_imm_scaled: "BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED"
        case .do_bind_uleb_times_skipping_uleb: "BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB"
        case .threaded: "BIND_OPCODE_THREADED"
        }
    }
}


public enum BindSubOpcode {
    case threaded_set_bind_ordinal_table_size_uleb
    case threaded_apply
}

extension BindSubOpcode: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case BIND_SUBOPCODE_THREADED_SET_BIND_ORDINAL_TABLE_SIZE_ULEB: self = .threaded_set_bind_ordinal_table_size_uleb
        case BIND_SUBOPCODE_THREADED_APPLY: self = .threaded_apply
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .threaded_set_bind_ordinal_table_size_uleb: BIND_SUBOPCODE_THREADED_SET_BIND_ORDINAL_TABLE_SIZE_ULEB
        case .threaded_apply: BIND_SUBOPCODE_THREADED_APPLY
        }
    }
}

extension BindSubOpcode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .threaded_set_bind_ordinal_table_size_uleb: "BIND_SUBOPCODE_THREADED_SET_BIND_ORDINAL_TABLE_SIZE_ULEB"
        case .threaded_apply: "BIND_SUBOPCODE_THREADED_APPLY"
        }
    }
}

