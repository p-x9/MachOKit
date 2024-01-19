//
//  DyldSubCacheEntry.swift
//
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public enum DyldSubCacheEntryType {
    case general
    case v1

    var layoutSize: Int {
        switch self {
        case .general:
            DyldSubCacheEntryGeneral.layoutSize
        case .v1:
            DyldSubCacheEntryV1.layoutSize
        }
    }
}

public enum DyldSubCacheEntry {
    case general(DyldSubCacheEntryGeneral)
    case v1(DyldSubCacheEntryV1)

    public var type: DyldSubCacheEntryType {
        switch self {
        case .general: .general
        case .v1: .v1
        }
    }

    public var uuid: UUID {
        switch self {
        case let .general(info): info.uuid
        case let .v1(info): info.uuid
        }
    }

    public var cacheVMOffset: UInt64 {
        switch self {
        case let .general(info): info.cacheVMOffset
        case let .v1(info): info.cacheVMOffset
        }
    }

    public var fileSuffix: String? {
        switch self {
        case let .general(info): info.fileSuffix
        case .v1: nil
        }
    }
}

public struct DyldSubCacheEntryV1: LayoutWrapper {
    public typealias Layout = dyld_subcache_entry_v1

    public var layout: Layout
}

extension DyldSubCacheEntryV1 {
    public var uuid: UUID {
        .init(uuid: layout.uuid)
    }
}

public struct DyldSubCacheEntryGeneral: LayoutWrapper {
    public typealias Layout = dyld_subcache_entry

    public var layout: Layout
}

extension DyldSubCacheEntryGeneral {
    public var uuid: UUID {
        .init(uuid: layout.uuid)
    }

    public var fileSuffix: String {
        .init(tuple: layout.fileSuffix)
    }
}
