//
//  DyldCacheTproMappingInfo.swift
//  MachOKit
//
//  Created by p-x9 on 2025/02/27
//  
//

import Foundation

public struct DyldCacheTproMappingInfo: LayoutWrapper, Sendable {
    public typealias Layout = dyld_cache_tpro_mapping_info

    public var layout: Layout

    /// Creates a wrapper for the given C layout.
    public init(layout: Layout) {
        self.layout = layout
    }
}
