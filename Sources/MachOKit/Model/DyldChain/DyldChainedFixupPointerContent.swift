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
}

// MARK: - Rebase & Bind Layout

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
