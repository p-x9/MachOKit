//
//  DyldCacheFunctionVariantInfo.swift
//  MachOKit
//
//  Created by p-x9 on 2025/05/12
//  
//

import Foundation
import MachOKitC

public struct DyldCacheFunctionVariantInfo: LayoutWrapper {
    public typealias Layout = dyld_cache_function_variant_info

    public var layout: Layout
    public var address: Int
}

extension DyldCacheFunctionVariantInfo {
    public func entries(in cache: DyldCacheLoaded) -> MemorySequence<DyldCacheFunctionVariantEntry>? {
        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        return .init(
            basePointer: basePointer
                .advanced(by: layoutOffset(of: \.entries))
                .assumingMemoryBound(to: DyldCacheFunctionVariantEntry.self),
            numberOfElements: numericCast(layout.count)
        )
    }

    public func entries(in cache: DyldCache) -> DataSequence<DyldCacheFunctionVariantEntry>? {
        guard let offset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        return cache.fileHandle.readDataSequence(
            offset: offset + numericCast(layoutOffset(of: \.entries)),
            numberOfElements: numericCast(layout.count)
        )
    }
}
