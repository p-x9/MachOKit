//
//  DyldCacheLocalSymbolsInfo.swift
//
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheLocalSymbolsInfo: LayoutWrapper {
    public typealias Layout = dyld_cache_local_symbols_info

    public var layout: Layout
}
