//
//  DyldChainedPointerFormat.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

public enum DyldChainedPointerFormat: UInt16 {
    /// DYLD_CHAINED_PTR_ARM64E
    case arm64e = 1
    /// DYLD_CHAINED_PTR_64
    case _64
    /// DYLD_CHAINED_PTR_32
    case _32
    /// DYLD_CHAINED_PTR_32_CACHE
    case _32_cache
    /// DYLD_CHAINED_PTR_32_FIRMWARE
    case _32_firmware
    /// DYLD_CHAINED_PTR_64_OFFSET
    case _64_offset
    /// DYLD_CHAINED_PTR_ARM64E_OFFSET
    case arm64e_offset
    /// DYLD_CHAINED_PTR_ARM64E_KERNEL
    case arm64e_kernel
    /// DYLD_CHAINED_PTR_64_KERNEL_CACHE
    case _64_kernel_cache
    /// DYLD_CHAINED_PTR_ARM64E_USERLAND
    case arm64e_userland
    /// DYLD_CHAINED_PTR_ARM64E_FIRMWARE
    case arm64e_firmware
    /// DYLD_CHAINED_PTR_X86_64_KERNEL_CACHE
    case x86_64_kernel_cache
    /// DYLD_CHAINED_PTR_ARM64E_USERLAND24
    case arm64e_userland24
}

extension DyldChainedPointerFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .arm64e: "DYLD_CHAINED_PTR_ARM64E"
        case ._64: "DYLD_CHAINED_PTR_64"
        case ._32: "DYLD_CHAINED_PTR_32"
        case ._32_cache: "DYLD_CHAINED_PTR_32_CACHE"
        case ._32_firmware: "DYLD_CHAINED_PTR_32_FIRMWARE"
        case ._64_offset: "DYLD_CHAINED_PTR_64_OFFSET"
        case .arm64e_offset: "DYLD_CHAINED_PTR_ARM64E_OFFSET"
        case .arm64e_kernel: "DYLD_CHAINED_PTR_ARM64E_KERNEL"
        case ._64_kernel_cache: "DYLD_CHAINED_PTR_64_KERNEL_CACHE"
        case .arm64e_userland: "DYLD_CHAINED_PTR_ARM64E_USERLAND"
        case .arm64e_firmware: "DYLD_CHAINED_PTR_ARM64E_FIRMWARE"
        case .x86_64_kernel_cache: "DYLD_CHAINED_PTR_X86_64_KERNEL_CACHE"
        case .arm64e_userland24: "DYLD_CHAINED_PTR_ARM64E_USERLAND24"
        }
    }
}
