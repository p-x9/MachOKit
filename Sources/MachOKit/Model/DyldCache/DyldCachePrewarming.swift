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
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset + layoutOffset(of: \.entries)),
            numberOfElements: numericCast(layout.count)
        )
    }
}

extension DyldCachePrewarming {
    public var size: Int {
        layoutSize + DyldCachePrewarmingEntry.layoutSize * numericCast(layout.count)
    }
}
