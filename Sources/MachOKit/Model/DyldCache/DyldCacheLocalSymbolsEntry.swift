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

    /// Creates a wrapper for the given C layout.
    public init(layout: Layout) {
        self.layout = layout
    }
}

extension DyldCacheLocalSymbolsEntry: DyldCacheLocalSymbolsEntryProtocol {
    /// Offset in cache file of start of dylib
    public var dylibOffset: Int {
        numericCast(layout.dylibOffset)
    }

    public var nlistStartIndex: Int {
        numericCast(layout.nlistStartIndex)
    }

    public var nlistCount: Int {
        numericCast(layout.nlistCount)
    }
}

public struct DyldCacheLocalSymbolsEntry64: LayoutWrapper {
    public typealias Layout = dyld_cache_local_symbols_entry_64

    public var layout: Layout

    /// Creates a wrapper for the given C layout.
    public init(layout: Layout) {
        self.layout = layout
    }
}

extension DyldCacheLocalSymbolsEntry64: DyldCacheLocalSymbolsEntryProtocol {
    /// Offset in cache buffer of start of dylib
    public var dylibOffset: Int {
        numericCast(layout.dylibOffset)
    }

    public var nlistStartIndex: Int {
        numericCast(layout.nlistStartIndex)
    }

    public var nlistCount: Int {
        numericCast(layout.nlistCount)
    }
}
