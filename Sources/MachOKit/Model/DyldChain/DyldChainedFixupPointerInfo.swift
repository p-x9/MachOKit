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

public protocol DyldChainedFixupPointerContent {
    var type: DyldChainedFixupPointerInfo.ContentType { get }
    var next: Int { get }

    var rebase: (any DyldChainedPointerContentRebase)? { get }
    var bind: (any DyldChainedPointerContentBind)? { get }
}

extension DyldChainedFixupPointerContent {
    public var isBind: Bool { type == .bind }
    public var isRebase: Bool { type == .rebase }
}

extension DyldChainedFixupPointerInfo {
    public enum ARM64E: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtrArm64eRebase)
        case bind(DyldChainedPtrArm64eBind)
        case authRebase(DyldChainedPtrArm64eAuthRebase)
        case authBind(DyldChainedPtrArm64eAuthBind)

        public var next: Int {
            switch self {
            case let .rebase(info): info.next
            case let .bind(info): info.next
            case let .authRebase(info): info.next
            case let .authBind(info): info.next
            }
        }

        public var type: DyldChainedFixupPointerInfo.ContentType {
            switch self {
            case .rebase: .rebase
            case .bind: .bind
            case .authRebase: .rebase
            case .authBind: .bind
            }
        }

        public var rebase: (any DyldChainedPointerContentRebase)? {
            switch self {
            case let .rebase(info): info
            case let .authRebase(info): info
            default: nil
            }
        }

        public var bind: (any DyldChainedPointerContentBind)? {
            switch self {
            case let .bind(info): info
            case let .authBind(info): info
            default: nil
            }
        }

        init(rawValue: UInt64) {
            let tmp = DyldChainedPtrArm64eRebase(layout: autoBitCast(rawValue))
            let isBind = tmp.layout.bind == 1
            let isAuth = tmp.layout.auth == 1

            switch (isBind, isAuth) {
            case (true, false): self = .bind(autoBitCast(rawValue))
            case (false, false): self = .rebase(autoBitCast(rawValue))
            case (true, true): self = .authBind(autoBitCast(rawValue))
            case (false, true): self = .authRebase(autoBitCast(rawValue))
            }
        }
    }

    public enum General64: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtr64Rebase)
        case bind(DyldChainedPtr64Bind)

        public var next: Int {
            switch self {
            case let .rebase(info): info.next
            case let .bind(info): info.next
            }
        }

        public var type: DyldChainedFixupPointerInfo.ContentType {
            switch self {
            case .rebase: .rebase
            case .bind: .bind
            }
        }

        public var rebase: (any DyldChainedPointerContentRebase)? {
            switch self {
            case let .rebase(info): info
            default: nil
            }
        }

        public var bind: (any DyldChainedPointerContentBind)? {
            switch self {
            case let .bind(info): info
            default: nil
            }
        }

        init(rawValue: UInt64) {
            let tmp = DyldChainedPtr64Rebase(layout: autoBitCast(rawValue))
            let isBind = tmp.layout.bind == 1

            if isBind {
                self = .bind(autoBitCast(rawValue))
            } else {
                self = .rebase(autoBitCast(rawValue))
            }
        }
    }

    public enum General64Cache: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtr64KernelCacheRebase)

        public var next: Int {
            switch self {
            case let .rebase(info): info.next
            }
        }

        public var type: DyldChainedFixupPointerInfo.ContentType {
            switch self {
            case .rebase: .rebase
            }
        }

        public var rebase: (any DyldChainedPointerContentRebase)? {
            switch self {
            case let .rebase(info): info
            }
        }

        public var bind: (any DyldChainedPointerContentBind)? { nil }

        init(rawValue: UInt64) {
            self = .rebase(autoBitCast(rawValue))
        }
    }

    public enum General32: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtr32Rebase)
        case bind(DyldChainedPtr32Bind)

        public var next: Int {
            switch self {
            case let .rebase(info): info.next
            case let .bind(info): info.next
            }
        }

        public var type: DyldChainedFixupPointerInfo.ContentType {
            switch self {
            case .rebase: .rebase
            case .bind: .bind
            }
        }

        public var rebase: (any DyldChainedPointerContentRebase)? {
            switch self {
            case let .rebase(info): info
            default: nil
            }
        }

        public var bind: (any DyldChainedPointerContentBind)? {
            switch self {
            case let .bind(info): info
            default: nil
            }
        }

        init(rawValue: UInt32) {
            let tmp = DyldChainedPtr32Rebase(layout: autoBitCast(rawValue))
            let isBind = tmp.layout.bind == 1

            if isBind {
                self = .bind(autoBitCast(rawValue))
            } else {
                self = .rebase(autoBitCast(rawValue))
            }
        }
    }

    public enum General32Cache: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtr32CacheRebase)

        public var next: Int {
            switch self {
            case let .rebase(info): info.next
            }
        }

        public var type: DyldChainedFixupPointerInfo.ContentType {
            switch self {
            case .rebase: .rebase
            }
        }

        public var rebase: (any DyldChainedPointerContentRebase)? {
            switch self {
            case let .rebase(info): info
            }
        }

        public var bind: (any DyldChainedPointerContentBind)? { nil }

        init(rawValue: UInt32) {
            self = .rebase(autoBitCast(rawValue))
        }
    }

    public enum General32Firmware: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtr32FirmwareRebase)

        public var next: Int {
            switch self {
            case let .rebase(info): info.next
            }
        }

        public var type: DyldChainedFixupPointerInfo.ContentType {
            switch self {
            case .rebase: .rebase
            }
        }

        public var rebase: (any DyldChainedPointerContentRebase)? {
            switch self {
            case let .rebase(info): info
            }
        }

        public var bind: (any DyldChainedPointerContentBind)? { nil }

        init(rawValue: UInt32) {
            self = .rebase(autoBitCast(rawValue))
        }
    }
}

public protocol DyldChainedPointerContentRebase: LayoutWrapper {
    var target: Int { get }
    var next: Int { get }
}

public protocol DyldChainedPointerContentBind: LayoutWrapper {
    var ordinal: Int { get }
    var next: Int { get }
}

public struct DyldChainedPtrArm64eRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_arm64e_rebase
    public var layout: Layout

    public var target: Int {
        numericCast(layout.target)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}

public struct DyldChainedPtrArm64eBind: DyldChainedPointerContentBind {
    public typealias Layout = dyld_chained_ptr_arm64e_bind
    public var layout: Layout

    public var ordinal: Int {
        numericCast(layout.ordinal)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}

public struct DyldChainedPtrArm64eAuthRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_arm64e_auth_rebase
    public var layout: Layout

    public var target: Int {
        numericCast(layout.target)
    }

    public var next: Int {
        numericCast(layout.next)
    }

    public var keyName: String {
        ["IA", "IB", "DA", "DB"][Int(layout.key)]
    }
}

public struct DyldChainedPtrArm64eAuthBind: DyldChainedPointerContentBind {
    public typealias Layout = dyld_chained_ptr_arm64e_auth_bind
    public var layout: Layout

    public var ordinal: Int {
        numericCast(layout.ordinal)
    }

    public var next: Int {
        numericCast(layout.next)
    }

    public var keyName: String {
        ["IA", "IB", "DA", "DB"][Int(layout.key)]
    }
}

public struct DyldChainedPtr64Rebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_64_rebase
    public var layout: Layout

    public var target: Int {
        numericCast(layout.target)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}

public struct DyldChainedPtr64Bind: DyldChainedPointerContentBind {
    public typealias Layout = dyld_chained_ptr_64_bind
    public var layout: Layout

    public var ordinal: Int {
        numericCast(layout.ordinal)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}

public struct DyldChainedPtr64KernelCacheRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_64_kernel_cache_rebase
    public var layout: Layout

    public var target: Int {
        numericCast(layout.target)
    }

    public var next: Int {
        numericCast(layout.next)
    }

    public var keyName: String {
        ["IA", "IB", "DA", "DB"][Int(layout.key)]
    }
}

public struct DyldChainedPtr32Rebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_32_rebase
    public var layout: Layout

    public var target: Int {
        numericCast(layout.target)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}

public struct DyldChainedPtr32Bind: DyldChainedPointerContentBind {
    public typealias Layout = dyld_chained_ptr_32_bind
    public var layout: Layout

    public var ordinal: Int {
        numericCast(layout.ordinal)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}

public struct DyldChainedPtr32CacheRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_32_cache_rebase
    public var layout: Layout

    public var target: Int {
        numericCast(layout.target)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}

public struct DyldChainedPtr32FirmwareRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_32_firmware_rebase
    public var layout: Layout

    public var target: Int {
        numericCast(layout.target)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}
