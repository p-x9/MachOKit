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
    /// Path for image
    /// - Parameter cache: DyldCache to which this image belongs
    /// - Returns: Path for image
    public func path(in cache: DyldCache) -> String? {
        _path(in: cache)
    }

    /// Path for image
    /// - Parameter cache: DyldCache to which this image belongs
    /// - Returns: Path for image
    public func path(in cache: DyldCacheLoaded) -> String? {
        String(
            cString: cache.ptr
                .advanced(by: numericCast(layout.pathFileOffset))
                .assumingMemoryBound(to: CChar.self)
        )
    }

    /// Path for image
    /// - Parameter cache: FullDyldCache to which this image belongs
    /// - Returns: Path for image
    public func path(in cache: FullDyldCache) -> String? {
        _path(in: cache)
    }
}

extension DyldCacheImageInfo {
    internal func _path<Cache: _DyldCacheFileRepresentable>(in cache: Cache) -> String? {
        cache.fileHandle.readString(
            offset: numericCast(layout.pathFileOffset)
        )
    }
}
