//
//  DyldChainedFixupPointerContent.swift
//
//
//  Created by p-x9 on 2024/02/20.
//  
//

import Foundation

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

    public enum ARM64EUserland24: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtrArm64eRebase)
        case bind(DyldChainedPtrArm64eBind24)
        case authRebase(DyldChainedPtrArm64eAuthRebase)
        case authBind(DyldChainedPtrArm64eAuthBind24)

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

    public enum ARM64ESharedCache: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtrArm64eSharedCacheRebase)
        case authRebase(DyldChainedPtrArm64eSharedCacheAuthRebase)

        public var next: Int {
            switch self {
            case let .rebase(info): info.next
            case let .authRebase(info): info.next
            }
        }

        public var type: DyldChainedFixupPointerInfo.ContentType {
            switch self {
            case .rebase: .rebase
            case .authRebase: .rebase
            }
        }

        public var rebase: (any DyldChainedPointerContentRebase)? {
            switch self {
            case let .rebase(info): info
            case let .authRebase(info): info
            }
        }

        public var bind: (any DyldChainedPointerContentBind)? {
            nil
        }

        init(rawValue: UInt64) {
            let tmp = DyldChainedPtrArm64eSharedCacheRebase(layout: autoBitCast(rawValue))
            let isAuth = tmp.layout.auth == 1

            if isAuth {
                self = .authRebase(autoBitCast(rawValue))
            } else {
                self = .rebase(tmp)
            }
        }
    }

    public enum ARM64ESegmented: DyldChainedFixupPointerContent {
        case rebase(DyldChainedPtrArm64eSegmentedRebase)
        case authRebase(DyldChainedPtrArm64eSegmentedAuthRebase)

        public var next: Int {
            switch self {
            case let .rebase(info): info.next
            case let .authRebase(info): info.next
            }
        }

        public var type: DyldChainedFixupPointerInfo.ContentType {
            switch self {
            case .rebase: .rebase
            case .authRebase: .rebase
            }
        }

        public var rebase: (any DyldChainedPointerContentRebase)? {
            switch self {
            case let .rebase(info): info
            case let .authRebase(info): info
            }
        }

        public var bind: (any DyldChainedPointerContentBind)? {
            nil
        }

        init(rawValue: UInt64) {
            let tmp = DyldChainedPtrArm64eSegmentedRebase(layout: autoBitCast(rawValue))
            let isAuth = tmp.layout.auth == 1

            if isAuth {
                self = .authRebase(autoBitCast(rawValue))
            } else {
                self = .rebase(tmp)
            }
        }
    }
}

// MARK: - Rebase & Bind Layout

public protocol DyldChainedPointerContentRebase: LayoutWrapper {
    var target: Int { get }
    var next: Int { get }
    var isAuth: Bool { get }
    var unpackedTarget: UInt64 { get }
}

extension DyldChainedPointerContentRebase {
    public var isAuth: Bool { false }
    public var unpackedTarget: UInt64 { numericCast(target) }
}

public protocol DyldChainedPointerContentBind: LayoutWrapper {
    var ordinal: Int { get }
    var next: Int { get }
    var addend: UInt64 { get }
    var signExtendedAddend: UInt64 { get }
    var isAuth: Bool { get }
}

extension DyldChainedPointerContentBind {
    public var addend: UInt64 { 0 }
    public var signExtendedAddend: UInt64 { addend }
    public var isAuth: Bool { false }
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

    public var unpackedTarget: UInt64 {
        (layout.high8 << 56) | layout.target
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

    public var addend: UInt64 {
        numericCast(layout.addend)
    }

    public var signExtendedAddend: UInt64 {
        let addend19 = layout.addend
        if (addend19 & 0x40000) != 0 {
            return addend19 | 0xFFFFFFFFFFFC0000
        } else {
            return addend19
        }
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

    public var isAuth: Bool { true }

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

    public var isAuth: Bool { true }

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

    public var unpackedTarget: UInt64 {
        (layout.high8 << 56) | layout.target
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

    public var addend: UInt64 {
        numericCast(layout.addend)
    }

    public var signExtendedAddend: UInt64 {
        let addend27 = layout.addend
        let top8Bits = addend27 & 0x00007F80000
        let bottom19Bits = addend27 & 0x0000007FFFF
        let newValue = (top8Bits << 13) | (((bottom19Bits << 37) >> 37) & 0x00FFFFFFFFFFFFFF)
        return newValue
    }
}

public struct DyldChainedPtrArm64eBind24: DyldChainedPointerContentBind {
    public typealias Layout = dyld_chained_ptr_arm64e_bind24

    public var layout: Layout

    public var ordinal: Int {
        numericCast(layout.ordinal)
    }

    public var next: Int {
        numericCast(layout.next)
    }

    public var addend: UInt64 {
        numericCast(layout.addend)
    }

    public var signExtendedAddend: UInt64 {
        let addend19 = layout.addend
        if (addend19 & 0x40000) != 0 {
            return addend19 | 0xFFFFFFFFFFFC0000
        } else {
            return addend19
        }
    }
}

public struct DyldChainedPtrArm64eAuthBind24: DyldChainedPointerContentBind {
    public typealias Layout = dyld_chained_ptr_arm64e_auth_bind24

    public var layout: Layout

    public var ordinal: Int {
        numericCast(layout.ordinal)
    }

    public var next: Int {
        numericCast(layout.next)
    }

    public var isAuth: Bool { true }

    public var keyName: String {
        ["IA", "IB", "DA", "DB"][Int(layout.key)]
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

    public var isAuth: Bool { layout.isAuth != 0 }

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

    public var addend: UInt64 {
        numericCast(layout.addend)
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

public struct DyldChainedPtrArm64eSharedCacheRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_arm64e_shared_cache_rebase

    public var layout: Layout

    public var target: Int {
        numericCast(layout.runtimeOffset)
    }

    public var next: Int {
        numericCast(layout.next)
    }

    public var unpackedTarget: UInt64 {
        (layout.high8 << 56) | layout.runtimeOffset
    }
}

public struct DyldChainedPtrArm64eSharedCacheAuthRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_arm64e_shared_cache_auth_rebase

    public var layout: Layout

    public var target: Int {
        numericCast(layout.runtimeOffset)
    }

    public var next: Int {
        numericCast(layout.next)
    }

    public var isAuth: Bool { true }

    public var keyName: String {
        ["IA", "DA"][Int(layout.keyIsData)]
    }
}


public struct DyldChainedPtrArm64eSegmentedRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_arm64e_segmented_rebase

    public var layout: Layout

    public var target: Int {
        numericCast(layout.targetSegOffset)
    }

    public var next: Int {
        numericCast(layout.next)
    }
}

public struct DyldChainedPtrArm64eSegmentedAuthRebase: DyldChainedPointerContentRebase {
    public typealias Layout = dyld_chained_ptr_arm64e_auth_segmented_rebase

    public var layout: Layout

    /// @available(*, unavailable)
    public var target: Int {
        0
    }

    /// @available(*, unavailable)
    public var unpackedTarget: UInt64 {
        0
    }

    public var next: Int {
        numericCast(layout.next)
    }

    public var isAuth: Bool { true }

    public var keyName: String {
        ["IA", "IB", "DA", "DB"][Int(layout.key)]
    }
}
