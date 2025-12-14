//
//  Rebase.swift
//  
//
//  Created by p-x9 on 2023/12/02.
//  
//

import Foundation

public enum RebaseOpcode: Sendable {
    /// REBASE_OPCODE_DONE
    case done
    /// REBASE_OPCODE_SET_TYPE_IMM
    case set_type_imm
    /// REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB
    case set_segment_and_offset_uleb
    /// REBASE_OPCODE_ADD_ADDR_ULEB
    case add_addr_uleb
    /// REBASE_OPCODE_ADD_ADDR_IMM_SCALED
    case add_addr_imm_scaled
    /// REBASE_OPCODE_DO_REBASE_IMM_TIMES
    case do_rebase_imm_times
    /// REBASE_OPCODE_DO_REBASE_ULEB_TIMES
    case do_rebase_uleb_times
    /// REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB
    case do_rebase_add_addr_uleb
    /// REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB
    case do_rebase_uleb_times_skipping_uleb
}

extension RebaseOpcode: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case REBASE_OPCODE_DONE: self = .done
        case REBASE_OPCODE_SET_TYPE_IMM: self = .set_type_imm
        case REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB: self = .set_segment_and_offset_uleb
        case REBASE_OPCODE_ADD_ADDR_ULEB: self = .add_addr_uleb
        case REBASE_OPCODE_ADD_ADDR_IMM_SCALED: self = .add_addr_imm_scaled
        case REBASE_OPCODE_DO_REBASE_IMM_TIMES: self = .do_rebase_imm_times
        case REBASE_OPCODE_DO_REBASE_ULEB_TIMES: self = .do_rebase_uleb_times
        case REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB: self = .do_rebase_add_addr_uleb
        case REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB: self = .do_rebase_uleb_times_skipping_uleb
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .done: REBASE_OPCODE_DONE
        case .set_type_imm: REBASE_OPCODE_SET_TYPE_IMM
        case .set_segment_and_offset_uleb: REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB
        case .add_addr_uleb: REBASE_OPCODE_ADD_ADDR_ULEB
        case .add_addr_imm_scaled: REBASE_OPCODE_ADD_ADDR_IMM_SCALED
        case .do_rebase_imm_times: REBASE_OPCODE_DO_REBASE_IMM_TIMES
        case .do_rebase_uleb_times: REBASE_OPCODE_DO_REBASE_ULEB_TIMES
        case .do_rebase_add_addr_uleb: REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB
        case .do_rebase_uleb_times_skipping_uleb: REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB
        }
    }
}

extension RebaseOpcode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .done: "REBASE_OPCODE_DONE"
        case .set_type_imm: "REBASE_OPCODE_SET_TYPE_IMM"
        case .set_segment_and_offset_uleb: "REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB"
        case .add_addr_uleb: "REBASE_OPCODE_ADD_ADDR_ULEB"
        case .add_addr_imm_scaled: "REBASE_OPCODE_ADD_ADDR_IMM_SCALED"
        case .do_rebase_imm_times: "REBASE_OPCODE_DO_REBASE_IMM_TIMES"
        case .do_rebase_uleb_times: "REBASE_OPCODE_DO_REBASE_ULEB_TIMES"
        case .do_rebase_add_addr_uleb: "REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB"
        case .do_rebase_uleb_times_skipping_uleb: "REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB"
        }
    }
}
