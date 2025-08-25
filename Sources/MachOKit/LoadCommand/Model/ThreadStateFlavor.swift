//
//  ThreadStateFlavor.swift
//  
//
//  Created by p-x9 on 2023/11/30.
//  
//

import Foundation

public enum ThreadStateFlavor: Sendable, CustomStringConvertible {
    case arm(ARMThreadStateFlavor)
    case i386(i386ThreadStateFlavor)
    case x86_64(x86ThreadStateFlavor)

    public var description: String {
        switch self {
        case let .arm(flavor): flavor.description
        case let .i386(flavor): flavor.description
        case let .x86_64(flavor): flavor.description
        }
    }
}

// MARK: - x86
public enum x86ThreadStateFlavor: UInt32, Sendable, CaseIterable {
    case thread_state32 = 1
    case float_state32
    case exception_state32
    case thread_state64
    case float_state64
    case exception_state64
    case thread_state
    case float_state
    case exception_state
    case debug_state32
    case debug_state64
    case debug_state
    case thread_state_none

    case avx_state32 = 16
    case avx_state64
    case avx_state

    case avx512_state32 = 19
    case avx512_state64
    case avx512_state

    case pagein_state = 22
    case thread_full_state64 = 23
    case instruction_state = 24
    case last_branch_state = 25
}

extension x86ThreadStateFlavor: CustomStringConvertible {
    public var description: String {
        switch self {
        case .thread_state32: "x86_THREAD_STATE32"
        case .float_state32: "x86_FLOAT_STATE32"
        case .exception_state32: "x86_EXCEPTION_STATE32"
        case .thread_state64: "x86_THREAD_STATE64"
        case .float_state64: "x86_FLOAT_STATE64"
        case .exception_state64: "x86_EXCEPTION_STATE64"
        case .thread_state: "x86_THREAD_STATE"
        case .float_state: "x86_FLOAT_STATE"
        case .exception_state: "x86_EXCEPTION_STATE"
        case .debug_state32: "x86_DEBUG_STATE32"
        case .debug_state64: "x86_DEBUG_STATE64"
        case .debug_state: "x86_DEBUG_STATE"
        case .thread_state_none: "THREAD_STATE_NONE"

        case .avx_state32: "x86_AVX_STATE32"
        case .avx_state64: "x86_AVX_STATE64"
        case .avx_state: "x86_AVX_STATE"
        case .avx512_state32: "x86_AVX512_STATE32"
        case .avx512_state64: "x86_AVX512_STATE64"
        case .avx512_state: "x86_AVX512_STATE"
        case .pagein_state: "x86_PAGEIN_STATE"
        case .thread_full_state64: "x86_THREAD_FULL_STATE64"
        case .instruction_state: "x86_INSTRUCTION_STATE"
        case .last_branch_state: "x86_LAST_BRANCH_STATE"
        }
    }

}

// MARK: - i386
public enum i386ThreadStateFlavor: UInt32, Sendable {
    case thread_state = 1
    case float_state
    case exception_state
}

extension i386ThreadStateFlavor: CustomStringConvertible {
    public var description: String {
        switch self {
        case .thread_state: "i386_THREAD_STATE"
        case .float_state: "i386_FLOAT_STATE"
        case .exception_state: "i386_EXCEPTION_STATE"
        }
    }
}

// MARK: - ARM
public enum ARMThreadStateFlavor: UInt32, Sendable {
    case thread_state = 1
//    case unified_thread_state = 1
    case vfp_state
    case exception_state
    case debug_state
    case thread_state_none
    case thread_state64
    case exception_state64
//    ARM_THREAD_STATE_LAST(8) legacy
    case thread_state32 = 9
}

extension ARMThreadStateFlavor: CustomStringConvertible {
    public var description: String {
        switch self {
        case .thread_state: "ARM_THREAD_STATE"
//        case .unified_thread_state: "ARM_UNIFIED_THREAD_STATE"
        case .vfp_state: "ARM_VFP_STATE"
        case .exception_state: "ARM_EXCEPTION_STATE"
        case .debug_state: "ARM_DEBUG_STATE"
        case .thread_state_none: "THREAD_STATE_NONE"
        case .thread_state64: "ARM_THREAD_STATE64"
        case .exception_state64: "ARM_EXCEPTION_STATE64"
        case .thread_state32: "ARM_THREAD_STATE32"
        }
    }
}
