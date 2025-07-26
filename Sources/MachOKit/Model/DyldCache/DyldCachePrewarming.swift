//
//  DyldCachePrewarming.swift
//  MachOKit
//
//  Created by p-x9 on 2025/05/13
//  
//

import Foundation
import MachOKitC

public struct DyldCachePrewarming: LayoutWrapper {
    public typealias Layout = dyld_prewarming_header

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
}

extension DyldCachePrewarming {
    public func entries(in cache: DyldCacheLoaded) -> MemorySequence<DyldCachePrewarmingEntry>? {
        .init(
            basePointer: cache.ptr
                .advanced(by: offset)
                .advanced(by: layoutOffset(of: \.entries))
                .assumingMemoryBound(to: DyldCachePrewarmingEntry.self),
            numberOfElements: numericCast(layout.count)
        )
    }

    public func entries(in cache: DyldCache) -> DataSequence<DyldCachePrewarmingEntry>? {
        _entries(in: cache)
    }

    public func entries(in cache: FullDyldCache) -> DataSequence<DyldCachePrewarmingEntry>? {
        _entries(in: cache)
    }
}

extension DyldCachePrewarming {
    internal func _entries<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DataSequence<DyldCachePrewarmingEntry>? {
        let offset = offset + layoutOffset(of: \.entries)
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let resolvedOffset = cache.fileOffset(
            of: sharedRegionStart + numericCast(offset)
        ) else {
            return nil
        }
        return cache.fileHandle.readDataSequence(
            offset: resolvedOffset,
            numberOfElements: numericCast(layout.count)
        )
    }
}

extension DyldCachePrewarming {
    public var size: Int {
        layoutSize + DyldCachePrewarmingEntry.layoutSize * numericCast(layout.count)
    }
}
