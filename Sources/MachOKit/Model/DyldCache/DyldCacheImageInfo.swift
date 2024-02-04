//
//  DyldCacheImageInfo.swift
//  
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheImageInfo: LayoutWrapper {
    public typealias Layout = dyld_cache_image_info

    public var layout: Layout
}

extension DyldCacheImageInfo {
    public func path(in cache: DyldCache) -> String? {
        cache.fileHandle.readString(
            offset: numericCast(layout.pathFileOffset),
            size: 1000 // FIXME
        )
    }
}
