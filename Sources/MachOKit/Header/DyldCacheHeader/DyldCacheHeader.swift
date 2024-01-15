//
//  DyldCacheHeader.swift
//
//
//  Created by p-x9 on 2024/01/14.
//  
//

import Foundation

public struct DyldCacheHeader: LayoutWrapper {
    public typealias Layout = dyld_cache_header

    public var layout: Layout
}

extension DyldCacheHeader {
    public var magic: String {
        .init(tuple: layout.magic)
    }

    public var uuid: UUID {
        .init(uuid: layout.uuid)
    }

    public var cacheType: DyldCacheType {
        .init(rawValue: layout.cacheType)!
    }

    public var cacheSubType: DyldCacheSubType? {
        guard cacheType == .multiCache else { return nil }
        return .init(rawValue: layout.cacheSubType)
    }

    public var platform: Platform {
        .init(rawValue: layout.platform) ?? .unknown
    }

    public var isSimulator: Bool {
        layout.simulator != 0
    }

    public var osVersion: Version {
        .init(layout.osVersion)
    }

    public var altPlatform: Platform {
        .init(rawValue: layout.altPlatform) ?? .unknown
    }

    public var altOsVersion: Version {
        .init(layout.altOsVersion)
    }

    public var symbolFileUUID: UUID {
        .init(uuid: layout.symbolFileUUID)
    }
}

extension DyldCacheHeader {
    // https://github.com/apple-oss-distributions/dyld/blob/d1a0f6869ece370913a3f749617e457f3b4cd7c4/dyld/SharedCacheRuntime.cpp#L100
    // https://github.com/opensource-apple/dyld/blob/3f928f32597888c5eac6003b9199d972d49857b5/src/dyld.cpp#L3112
    internal var _cpuType: CPUType? {
        switch magic {
        case "dyld_v1    i386": return .i386
        case "dyld_v1  x86_64": return .x86_64
        case "dyld_v1 x86_64h": return .x86_64
        case "dyld_v1   armv5": return .arm
        case "dyld_v1   armv6": return .arm
        case "dyld_v1  armv7f": return .arm
        case "dyld_v1  armv7k": return .arm
        case "dyld_v1   armv7": return .arm
        case "dyld_v1  armv7s": return .arm
        case "dyld_v1  arm64e": return .arm64
        case "dyld_v1   arm64": return .arm64
        case "dyld_v1arm64_32": return .arm64_32
        default: return nil
        }
    }

    internal var _cpuSubType: CPUSubType? {
        switch magic {
        case "dyld_v1    i386": return .i386(.i386_all)
        case "dyld_v1  x86_64": return .x86(.x86_64_all)
        case "dyld_v1 x86_64h": return .x86(.x86_64_h)
        case "dyld_v1   armv5": return .arm(.arm_v5tej) // == CPU_SUBTYPE_ARM_V5
        case "dyld_v1   armv6": return .arm(.arm_v6)
        case "dyld_v1  armv7f": return .arm(.arm_v7f)
        case "dyld_v1  armv7k": return .arm(.arm_v7k)
        case "dyld_v1   armv7": return .arm(.arm_v7)
        case "dyld_v1  armv7s": return .arm(.arm_v7s)
        case "dyld_v1  arm64e": return .arm64(.arm64_all)
        case "dyld_v1   arm64": return .arm64(.arm64_all)
        case "dyld_v1arm64_32": return .arm64_32(.arm64_32_all)
        default: return nil
        }
    }
}
