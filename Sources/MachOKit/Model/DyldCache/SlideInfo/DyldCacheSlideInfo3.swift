//
//  DyldCacheSlideInfo3.swift
//
//
//  Created by p-x9 on 2024/07/24
//  
//

import Foundation
import MachOKitC

public struct DyldCacheSlideInfo3: LayoutWrapper {
    public typealias Layout = dyld_cache_slide_info3

    public var layout: Layout
    public var offset: Int
}

// MARK: - PageStart
extension DyldCacheSlideInfo3 {
    public struct PageStart {
        public let value: UInt16

        public var isNoRebase: Bool {
            value == DYLD_CACHE_SLIDE_V3_PAGE_ATTR_NO_REBASE
        }
    }
}

// MARK: - function & proerty
extension DyldCacheSlideInfo3 {
    public var pageSize: Int {
        numericCast(layout.page_size)
    }
}

extension DyldCacheSlideInfo3 {
    public var numberOfPageStarts: Int {
        numericCast(layout.page_starts_count)
    }

    public func pageStarts(in cache: DyldCache) -> DataSequence<PageStart>? {
        let pageStartsOffset = layoutSize
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(pageStartsOffset),
            numberOfElements: numberOfPageStarts
        )
    }
}
