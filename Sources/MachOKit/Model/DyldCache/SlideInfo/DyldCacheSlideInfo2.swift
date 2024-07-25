//
//  DyldCacheSlideInfo2.swift
//
//
//  Created by p-x9 on 2024/07/23
//  
//

import Foundation
import MachOKitC

public struct DyldCacheSlideInfo2: LayoutWrapper {
    public typealias Layout = dyld_cache_slide_info2

    public var layout: Layout
    public var offset: Int
}

// MARK: - PageStart
extension DyldCacheSlideInfo2 {
    public struct PageStart {
        public let value: UInt16

        public var isNoRebase: Bool {
            value == DYLD_CACHE_SLIDE_PAGE_ATTR_NO_REBASE
        }

        public var isExtra: Bool {
            (value & UInt16(DYLD_CACHE_SLIDE_PAGE_ATTR_EXTRA)) > 0
        }

        public var extrasStartIndex: Int? {
            guard isExtra else { return nil }
            return numericCast(value & ~UInt16(DYLD_CACHE_SLIDE_PAGE_ATTRS))
        }
    }
}

// MARK: - PageExtra
extension DyldCacheSlideInfo2 {
    public struct PageExtra {
        public let value: UInt16

        public var isEnd: Bool {
            (value & UInt16(DYLD_CACHE_SLIDE_PAGE_ATTR_END)) > 0
        }
    }
}

// MARK: - function & proerty
extension DyldCacheSlideInfo2 {
    public var pageSize: Int {
        numericCast(layout.page_size)
    }
}

extension DyldCacheSlideInfo2 {
    public var numberOfPageStarts: Int {
        numericCast(layout.page_starts_count)
    }

    public func pageStarts(in cache: DyldCache) -> DataSequence<PageStart>? {
        guard layout.page_starts_offset > 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(layout.page_starts_offset),
            numberOfElements: numberOfPageStarts
        )
    }
}

extension DyldCacheSlideInfo2 {
    public var numberOfPageExtras: Int {
        numericCast(layout.page_extras_count)
    }

    public func pageExtras(in cache: DyldCache) -> DataSequence<PageExtra>? {
        guard layout.page_extras_offset > 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(layout.page_extras_offset),
            numberOfElements: numberOfPageExtras
        )
    }
}
