//
//  DyldChainedFixupPointerInfo.swift
//
//
//  Created by p-x9 on 2024/02/17.
//  
//

import Foundation

// https://github.com/apple-oss-distributions/dyld/blob/d1a0f6869ece370913a3f749617e457f3b4cd7c4/common/MachOLayout.cpp#L2094

public enum DyldChainedFixupPointerInfo {
    /// DYLD_CHAINED_PTR_ARM64E
    case arm64e(ARM64E)
    /// DYLD_CHAINED_PTR_64
    case _64(General64)
    /// DYLD_CHAINED_PTR_32
    case _32(General32)
    /// DYLD_CHAINED_PTR_32_CACHE
    case _32_cache(General32Cache)
    /// DYLD_CHAINED_PTR_32_FIRMWARE
    case _32_firmware(General32Firmware)
    /// DYLD_CHAINED_PTR_64_OFFSET
    case _64_offset(General64)
    /// DYLD_CHAINED_PTR_ARM64E_KERNEL
    case arm64e_kernel(ARM64E)
    /// DYLD_CHAINED_PTR_64_KERNEL_CACHE
    case _64_kernel_cache(General64Cache)
    /// DYLD_CHAINED_PTR_ARM64E_USERLAND
    case arm64e_userland(ARM64E)
    /// DYLD_CHAINED_PTR_ARM64E_FIRMWARE
    case arm64e_firmware(ARM64E)
    /// DYLD_CHAINED_PTR_X86_64_KERNEL_CACHE
    case x86_64_kernel_cache(General64Cache)
    /// DYLD_CHAINED_PTR_ARM64E_USERLAND24
    case arm64e_userland24(ARM64E)
}

extension DyldChainedFixupPointerInfo {
    public var pointerFormat: DyldChainedPointerFormat {
        switch self {
        case .arm64e: .arm64e
        case ._64: ._64
        case ._32: ._32
        case ._32_cache: ._32_cache
        case ._32_firmware: ._32_firmware
        case ._64_offset: ._64_offset
        case .arm64e_kernel: .arm64e_kernel
        case ._64_kernel_cache: ._64_kernel_cache
        case .arm64e_userland: .arm64e_userland
        case .arm64e_firmware: .arm64e_firmware
        case .x86_64_kernel_cache: .x86_64_kernel_cache
        case .arm64e_userland24: .arm64e_userland24
        }
    }
}

extension DyldChainedFixupPointerInfo {
    public var next: Int {
        switch self {
        case let .arm64e(info): info.next
        case let ._64(info): info.next
        case let ._32(info): info.next
        case let ._32_cache(info): info.next
        case let ._32_firmware(info): info.next
        case let ._64_offset(info): info.next
        case let .arm64e_kernel(info): info.next
        case let ._64_kernel_cache(info): info.next
        case let .arm64e_userland(info): info.next
        case let .arm64e_firmware(info): info.next
        case let .x86_64_kernel_cache(info): info.next
        case let .arm64e_userland24(info): info.next
        }
    }

    public var type: ContentType {
        switch self {
        case let .arm64e(info): info.type
        case let ._64(info): info.type
        case let ._32(info): info.type
        case let ._32_cache(info): info.type
        case let ._32_firmware(info): info.type
        case let ._64_offset(info): info.type
        case let .arm64e_kernel(info): info.type
        case let ._64_kernel_cache(info): info.type
        case let .arm64e_userland(info): info.type
        case let .arm64e_firmware(info): info.type
        case let .x86_64_kernel_cache(info): info.type
        case let .arm64e_userland24(info): info.type
        }
    }

    public var rebase: (any DyldChainedPointerContentRebase)? {
        switch self {
        case let .arm64e(info): info.rebase
        case let ._64(info): info.rebase
        case let ._32(info): info.rebase
        case let ._32_cache(info): info.rebase
        case let ._32_firmware(info): info.rebase
        case let ._64_offset(info): info.rebase
        case let .arm64e_kernel(info): info.rebase
        case let ._64_kernel_cache(info): info.rebase
        case let .arm64e_userland(info): info.rebase
        case let .arm64e_firmware(info): info.rebase
        case let .x86_64_kernel_cache(info): info.rebase
        case let .arm64e_userland24(info): info.rebase
        }
    }

    public var bind: (any DyldChainedPointerContentBind)? {
        switch self {
        case let .arm64e(info): info.bind
        case let ._64(info): info.bind
        case let ._32(info): info.bind
        case let ._32_cache(info): info.bind
        case let ._32_firmware(info): info.bind
        case let ._64_offset(info): info.bind
        case let .arm64e_kernel(info): info.bind
        case let ._64_kernel_cache(info): info.bind
        case let .arm64e_userland(info): info.bind
        case let .arm64e_firmware(info): info.bind
        case let .x86_64_kernel_cache(info): info.bind
        case let .arm64e_userland24(info): info.bind
        }
    }
}

extension DyldChainedFixupPointerInfo {
    public enum ContentType {
        case bind
        case rebase
    }
}
