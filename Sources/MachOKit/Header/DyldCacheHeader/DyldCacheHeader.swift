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
