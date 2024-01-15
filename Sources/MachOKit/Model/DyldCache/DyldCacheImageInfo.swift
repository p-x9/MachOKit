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
        cache.fileHandle.seek(
            toFileOffset: numericCast(layout.pathFileOffset)
        )
        let data = cache.fileHandle.readData(
            ofLength: 1000 // FIXME
        )
        return data.withUnsafeBytes {
            guard let base = $0.baseAddress else { return nil }
            let ptr = base.assumingMemoryBound(to: CChar.self)
            return .init(cString: ptr)
        }
    }
}
