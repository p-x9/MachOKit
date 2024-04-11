//
//  DyldCacheMappingInfo.swift
//
//
//  Created by p-x9 on 2024/01/15.
//
//

import Foundation

public struct DyldCacheMappingInfo: LayoutWrapper {
    public typealias Layout = dyld_cache_mapping_info

    public var layout: Layout
}

extension DyldCacheMappingInfo {
    /// Max vm protection of this mapping
    public var maxProtection: VMProtection {
        .init(rawValue: VMProtection.RawValue(bitPattern: layout.maxProt))
    }

    /// Initial vm protection of this mapping
    public var initialProtection: VMProtection {
        .init(rawValue: VMProtection.RawValue(bitPattern: layout.maxProt))
    }
}
