//
//  DyldCacheSlideInfo1.swift
//
//
//  Created by p-x9 on 2024/07/23
//  
//

import Foundation
import MachOKitC

public struct DyldCacheSlideInfo1: LayoutWrapper {
    public typealias Layout = dyld_cache_slide_info

    public var layout: Layout
    public var offset: Int
}

extension DyldCacheSlideInfo1 {
    public struct Entry: LayoutWrapper {
        public typealias Layout = dyld_cache_slide_info_entry

        public var layout: Layout
    }
}

extension DyldCacheSlideInfo1 {
    public var numberOfTableContents: Int {
        numericCast(layout.toc_count)
    }

    public func toc(in cache: DyldCache) -> DataSequence<UInt16>? {
        guard layout.toc_offset > 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(layout.toc_offset),
            numberOfElements: numberOfTableContents
        )
    }
}

extension DyldCacheSlideInfo1 {
    public var numberOfEntries: Int {
        numericCast(layout.entries_count)
    }

    public func entries(in cache: DyldCache) -> DataSequence<Entry>? {
        precondition(layout.entries_size == Entry.layoutSize)
        guard layout.entries_offset > 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) +  numericCast(layout.entries_offset),
            numberOfElements: numberOfEntries
        )
    }
}

