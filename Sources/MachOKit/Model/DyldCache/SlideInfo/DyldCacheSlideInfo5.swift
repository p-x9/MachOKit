//
//  DyldCacheSlideInfo5.swift
//
//
//  Created by p-x9 on 2024/07/25
//  
//

import Foundation
import MachOKitC

public struct DyldCacheSlideInfo5: LayoutWrapper, Sendable {
    public typealias Layout = dyld_cache_slide_info5

    public var layout: Layout
    public var offset: Int
}

// MARK: - PageStart
extension DyldCacheSlideInfo5 {
    public struct PageStart {
        public let value: UInt16

        public var isNoRebase: Bool {
            value == DYLD_CACHE_SLIDE_V5_PAGE_ATTR_NO_REBASE
        }
    }
}

// MARK: - function & proerty
extension DyldCacheSlideInfo5 {
    public var pageSize: Int {
        numericCast(layout.page_size)
    }
}

extension DyldCacheSlideInfo5 {
    public var numberOfPageStarts: Int {
        numericCast(layout.page_starts_count)
    }

    public func pageStarts(in cache: DyldCache) -> DataSequence<PageStart>? {
        _pageStarts(in: cache)
    }

    public func pageStarts(in cache: FullDyldCache) -> DataSequence<PageStart>? {
        _pageStarts(in: cache)
    }
}

extension DyldCacheSlideInfo5 {
    internal func _pageStarts<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DataSequence<PageStart>? {
        let pageStartsOffset = layoutSize
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(pageStartsOffset),
            numberOfElements: numberOfPageStarts
        )
    }
}
