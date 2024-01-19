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
    public var flags: DyldCacheMappingFlags {
        .init(rawValue: layout.flags)
    }
    
    public var maxProtection: VMProtection {
        .init(rawValue: VMProtection.RawValue(bitPattern: layout.maxProt))
    }

    public var initialProtection: VMProtection {
        .init(rawValue: VMProtection.RawValue(bitPattern: layout.maxProt))
    }
}
