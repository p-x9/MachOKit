//
//  DyldCacheSlideInfo4.swift
//
//
//  Created by p-x9 on 2024/07/24
//  
//

import Foundation
import MachOKitC

public struct DyldCacheSlideInfo4: LayoutWrapper, Sendable {
    public typealias Layout = dyld_cache_slide_info4

    public var layout: Layout
    public var offset: Int
}

// MARK: - PageStart
extension DyldCacheSlideInfo4 {
    public struct PageStart {
        public let value: UInt16

        public var isNoRebase: Bool {
            value == DYLD_CACHE_SLIDE4_PAGE_NO_REBASE
        }

        public var isUseExtra: Bool {
            (value & UInt16(DYLD_CACHE_SLIDE4_PAGE_USE_EXTRA)) > 0
        }

        public var extrasStartIndex: Int? {
            guard isUseExtra else { return nil }
            return numericCast(value & UInt16(DYLD_CACHE_SLIDE4_PAGE_INDEX))
        }
    }
}

// MARK: - PageExtra
extension DyldCacheSlideInfo4 {
    public struct PageExtra {
        public let value: UInt16

        public var isEnd: Bool {
            (value & UInt16(DYLD_CACHE_SLIDE4_PAGE_EXTRA_END)) > 0
        }
    }
}

// MARK: - function & proerty
extension DyldCacheSlideInfo4 {
    public var pageSize: Int {
        numericCast(layout.page_size)
    }
}

extension DyldCacheSlideInfo4 {
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

extension DyldCacheSlideInfo4 {
    internal func _pageStarts<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DataSequence<PageStart>? {
        cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(layout.page_starts_offset),
            numberOfElements: numberOfPageStarts
        )
    }
}

extension DyldCacheSlideInfo4 {
    public var numberOfPageExtras: Int {
        numericCast(layout.page_extras_count)
    }

    public func pageExtras(in cache: DyldCache) -> DataSequence<PageExtra>? {
        _pageExtras(in: cache)
    }

    public func pageExtras(in cache: FullDyldCache) -> DataSequence<PageExtra>? {
        _pageExtras(in: cache)
    }
}

extension DyldCacheSlideInfo4 {
    internal func _pageExtras<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DataSequence<PageExtra>? {
        guard layout.page_extras_offset > 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(layout.page_extras_offset),
            numberOfElements: numberOfPageExtras
        )
    }
}
