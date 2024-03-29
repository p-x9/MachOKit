//
//  DyldCacheImageTextInfo.swift
//  
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheImageTextInfo: LayoutWrapper {
    public typealias Layout = dyld_cache_image_text_info

    public var layout: Layout
}

extension DyldCacheImageTextInfo {
    public var uuid: UUID {
        .init(uuid: layout.uuid)
    }

    public func path(in cache: DyldCache) -> String? {
        cache.fileHandle.readString(
            offset: numericCast(layout.pathOffset),
            size: 1000 // FIXME
        )
    }
}
