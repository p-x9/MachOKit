//
//  DyldCacheLocalSymbolsEntry.swift
//  
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheLocalSymbolsEntry: LayoutWrapper, Sendable {
    public typealias Layout = dyld_cache_local_symbols_entry

    public var layout: Layout
}

extension DyldCacheLocalSymbolsEntry: DyldCacheLocalSymbolsEntryProtocol {
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

public struct DyldCacheLocalSymbolsEntry64: LayoutWrapper, Sendable {
    public typealias Layout = dyld_cache_local_symbols_entry_64

    public var layout: Layout
}

extension DyldCacheLocalSymbolsEntry64: DyldCacheLocalSymbolsEntryProtocol {
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
