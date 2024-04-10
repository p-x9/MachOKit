//
//  DyldCacheMappingAndSlideInfo.swift
//
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheMappingAndSlideInfo: LayoutWrapper {
    public typealias Layout = dyld_cache_mapping_and_slide_info

    public var layout: Layout
}

extension DyldCacheMappingAndSlideInfo {
    /// Flags of mapping
    public var flags: DyldCacheMappingFlags {
        .init(rawValue: layout.flags)
    }

    /// Max vm protection of this mapping
    public var maxProtection: VMProtection {
        .init(rawValue: VMProtection.RawValue(bitPattern: layout.maxProt))
    }

    /// Initial vm protection of this mapping
    public var initialProtection: VMProtection {
        .init(rawValue: VMProtection.RawValue(bitPattern: layout.maxProt))
    }
}
