//
//  RebaseOperation.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public enum RebaseOperation {
    case done
    case set_type_imm(RebaseType)
    case set_segment_and_offset_uleb(segment: Int, offset: UInt)
    case add_addr_uleb(offset: UInt)
    case add_addr_imm_scaled(scale: UInt)
    case do_rebase_imm_times(count: UInt)
    case do_rebase_uleb_times(count: UInt)
    case do_rebase_add_addr_uleb(offset: UInt)
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
