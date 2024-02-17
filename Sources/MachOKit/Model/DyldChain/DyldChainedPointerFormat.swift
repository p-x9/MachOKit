//
//  DyldChainedPointerFormat.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

public enum DyldChainedPointerFormat {
    /// DYLD_CHAINED_PTR_ARM64E
    case arm64e
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
//    /// DYLD_CHAINED_PTR_ARM64E_OFFSET
//    case arm64e_offset
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
//        case .arm64e_offset: "DYLD_CHAINED_PTR_ARM64E_OFFSET"
        case .arm64e_kernel: "DYLD_CHAINED_PTR_ARM64E_KERNEL"
        case ._64_kernel_cache: "DYLD_CHAINED_PTR_64_KERNEL_CACHE"
        case .arm64e_userland: "DYLD_CHAINED_PTR_ARM64E_USERLAND"
        case .arm64e_firmware: "DYLD_CHAINED_PTR_ARM64E_FIRMWARE"
        case .x86_64_kernel_cache: "DYLD_CHAINED_PTR_X86_64_KERNEL_CACHE"
        case .arm64e_userland24: "DYLD_CHAINED_PTR_ARM64E_USERLAND24"
        }
    }
}

extension DyldChainedPointerFormat: RawRepresentable {
    public typealias RawValue = UInt16

    public init?(rawValue: RawValue) {
        switch rawValue {
        case UInt16(DYLD_CHAINED_PTR_ARM64E): self = .arm64e
        case UInt16(DYLD_CHAINED_PTR_64): self = ._64
        case UInt16(DYLD_CHAINED_PTR_32): self = ._32
        case UInt16(DYLD_CHAINED_PTR_32_CACHE): self = ._32_cache
        case UInt16(DYLD_CHAINED_PTR_32_FIRMWARE): self = ._32_firmware
        case UInt16(DYLD_CHAINED_PTR_64_OFFSET): self = ._64_offset
//        case UInt16(DYLD_CHAINED_PTR_ARM64E_OFFSET): self = .arm64e_offset
        case UInt16(DYLD_CHAINED_PTR_ARM64E_KERNEL): self = .arm64e_kernel
        case UInt16(DYLD_CHAINED_PTR_64_KERNEL_CACHE): self = ._64_kernel_cache
        case UInt16(DYLD_CHAINED_PTR_ARM64E_USERLAND): self = .arm64e_userland
        case UInt16(DYLD_CHAINED_PTR_ARM64E_FIRMWARE): self = .arm64e_firmware
        case UInt16(DYLD_CHAINED_PTR_X86_64_KERNEL_CACHE): self = .x86_64_kernel_cache
        case UInt16(DYLD_CHAINED_PTR_ARM64E_USERLAND24): self = .arm64e_userland24
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .arm64e: UInt16(DYLD_CHAINED_PTR_ARM64E)
        case ._64: UInt16(DYLD_CHAINED_PTR_64)
        case ._32: UInt16(DYLD_CHAINED_PTR_32)
        case ._32_cache: UInt16(DYLD_CHAINED_PTR_32_CACHE)
        case ._32_firmware: UInt16(DYLD_CHAINED_PTR_32_FIRMWARE)
        case ._64_offset: UInt16(DYLD_CHAINED_PTR_64_OFFSET)
//        case .arm64e_offset: UInt16(DYLD_CHAINED_PTR_ARM64E_OFFSET)
        case .arm64e_kernel: UInt16(DYLD_CHAINED_PTR_ARM64E_KERNEL)
        case ._64_kernel_cache: UInt16(DYLD_CHAINED_PTR_64_KERNEL_CACHE)
        case .arm64e_userland: UInt16(DYLD_CHAINED_PTR_ARM64E_USERLAND)
        case .arm64e_firmware: UInt16(DYLD_CHAINED_PTR_ARM64E_FIRMWARE)
        case .x86_64_kernel_cache: UInt16(DYLD_CHAINED_PTR_X86_64_KERNEL_CACHE)
        case .arm64e_userland24: UInt16(DYLD_CHAINED_PTR_ARM64E_USERLAND24)
        }
    }
}
