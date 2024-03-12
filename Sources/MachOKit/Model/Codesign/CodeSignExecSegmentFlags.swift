//
//  CodeSignExecSegmentFlags.swift
//
//
//  Created by p-x9 on 2024/03/06.
//
//

import Foundation
import MachOKitC

public struct CodeSignExecSegmentFlags: BitFlags {
    public typealias RawValue = UInt64

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension CodeSignExecSegmentFlags {
    /// CS_EXECSEG_MAIN_BINARY
    public static let main_binary = CodeSignExecSegmentFlags(
        rawValue: Bit.main_binary.rawValue
    )
    /// CS_EXECSEG_ALLOW_UNSIGNED
    public static let allow_unsigned = CodeSignExecSegmentFlags(
        rawValue: Bit.allow_unsigned.rawValue
    )
    /// CS_EXECSEG_DEBUGGER
    public static let debugger = CodeSignExecSegmentFlags(
        rawValue: Bit.debugger.rawValue
    )
    /// CS_EXECSEG_JIT
    public static let jit = CodeSignExecSegmentFlags(
        rawValue: Bit.jit.rawValue
    )
    /// CS_EXECSEG_SKIP_LV
    public static let skip_lv = CodeSignExecSegmentFlags(
        rawValue: Bit.skip_lv.rawValue
    )
    /// CS_EXECSEG_CAN_LOAD_CDHASH
    public static let can_load_cdhash = CodeSignExecSegmentFlags(
        rawValue: Bit.can_load_cdhash.rawValue
    )
    /// CS_EXECSEG_CAN_EXEC_CDHASH
    public static let can_exec_cdhash = CodeSignExecSegmentFlags(
        rawValue: Bit.can_exec_cdhash.rawValue
    )
}

extension CodeSignExecSegmentFlags {
    public enum Bit: CaseIterable {
        /// CS_EXECSEG_MAIN_BINARY
        case main_binary
        /// CS_EXECSEG_ALLOW_UNSIGNED
        case allow_unsigned
        /// CS_EXECSEG_DEBUGGER
        case debugger
        /// CS_EXECSEG_JIT
        case jit
        /// CS_EXECSEG_SKIP_LV
        case skip_lv
        /// CS_EXECSEG_CAN_LOAD_CDHASH
        case can_load_cdhash
        /// CS_EXECSEG_CAN_EXEC_CDHASH
        case can_exec_cdhash
    }
}

extension CodeSignExecSegmentFlags.Bit: RawRepresentable {
    public typealias RawValue = UInt64

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(CS_EXECSEG_MAIN_BINARY): self = .main_binary
        case RawValue(CS_EXECSEG_ALLOW_UNSIGNED): self = .allow_unsigned
        case RawValue(CS_EXECSEG_DEBUGGER): self = .debugger
        case RawValue(CS_EXECSEG_JIT): self = .jit
        case RawValue(CS_EXECSEG_SKIP_LV): self = .skip_lv
        case RawValue(CS_EXECSEG_CAN_LOAD_CDHASH): self = .can_load_cdhash
        case RawValue(CS_EXECSEG_CAN_EXEC_CDHASH): self = .can_exec_cdhash
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .main_binary: RawValue(CS_EXECSEG_MAIN_BINARY)
        case .allow_unsigned: RawValue(CS_EXECSEG_ALLOW_UNSIGNED)
        case .debugger: RawValue(CS_EXECSEG_DEBUGGER)
        case .jit: RawValue(CS_EXECSEG_JIT)
        case .skip_lv: RawValue(CS_EXECSEG_SKIP_LV)
        case .can_load_cdhash: RawValue(CS_EXECSEG_CAN_LOAD_CDHASH)
        case .can_exec_cdhash: RawValue(CS_EXECSEG_CAN_EXEC_CDHASH)
        }
    }
}

extension CodeSignExecSegmentFlags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .main_binary: "CS_EXECSEG_MAIN_BINARY"
        case .allow_unsigned: "CS_EXECSEG_ALLOW_UNSIGNED"
        case .debugger: "CS_EXECSEG_DEBUGGER"
        case .jit: "CS_EXECSEG_JIT"
        case .skip_lv: "CS_EXECSEG_SKIP_LV"
        case .can_load_cdhash: "CS_EXECSEG_CAN_LOAD_CDHASH"
        case .can_exec_cdhash: "CS_EXECSEG_CAN_EXEC_CDHASH"
        }
    }
}
