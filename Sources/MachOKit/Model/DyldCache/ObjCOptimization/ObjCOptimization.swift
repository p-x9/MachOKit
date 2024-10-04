//
//  ObjCOptimization.swift
//
//
//  Created by p-x9 on 2024/05/29
//  
//

import Foundation
import MachOKitC

public struct ObjCOptimization: LayoutWrapper {
    public typealias Layout = objc_optimization

    public var layout: Layout
}

// MARK: Header Optimization RW
// https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/common/DyldSharedCache.cpp#L1892
extension ObjCOptimization {
    public func headerOptimizationRW64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        guard layout.headerInfoRWCacheOffset > 0 else {
            return nil
        }
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let offset = cache.fileOffset(
            of: sharedRegionStart + numericCast(layout.headerInfoRWCacheOffset)
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRW64.Layout =  cache.fileHandle.read(offset: offset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    public func headerOptimizationRW32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        guard layout.headerInfoRWCacheOffset > 0 else {
            return nil
        }
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let offset = cache.fileOffset(
            of: sharedRegionStart + numericCast(layout.headerInfoRWCacheOffset)
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRW32.Layout =  cache.fileHandle.read(offset: offset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}
