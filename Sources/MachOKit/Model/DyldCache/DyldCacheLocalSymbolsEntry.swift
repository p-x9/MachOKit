//
//  DyldCacheLocalSymbolsEntry.swift
//  
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheLocalSymbolsEntry: LayoutWrapper {
    public typealias Layout = dyld_cache_local_symbols_entry

    public var layout: Layout
}
