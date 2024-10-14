//
//  OldObjCOptimization.swift
//  
//
//  Created by p-x9 on 2024/10/06
//  
//

import Foundation
import MachOKitC

public struct OldObjCOptimization: LayoutWrapper {
    public typealias Layout = objc_opt_t

    public var layout: Layout
    // offset from file starts
    public let offset: Int
}

extension OldObjCOptimization {
    public func relativeMethodSelectorBaseAddress(
        in cache: DyldCacheLoaded
    ) -> UnsafeRawPointer {
        cache.ptr
            .advanced(by: offset)
            .advanced(
                by: numericCast(layout.relativeMethodSelectorBaseAddressOffset)
            )
    }
}

extension OldObjCOptimization {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        guard layout.headeropt_rw_offset > 0 else {
            return nil
        }
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let offset = cache.fileOffset(
            of: sharedRegionStart + numericCast(offset) + numericCast(layout.headeropt_rw_offset)
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRW64.Layout =  cache.fileHandle.read(offset: offset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        guard layout.headeropt_rw_offset > 0 else {
            return nil
        }
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let offset = cache.fileOffset(
            of: sharedRegionStart + numericCast(offset) + numericCast(layout.headeropt_rw_offset)
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

extension OldObjCOptimization {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW64? {
        guard layout.headeropt_rw_offset > 0 else {
            return nil
        }
        let offset: Int = numericCast(offset) + numericCast(layout.headeropt_rw_offset)
        let layout: ObjCHeaderOptimizationRW64.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW32? {
        guard layout.headeropt_rw_offset > 0 else {
            return nil
        }
        let offset: Int = numericCast(offset) + numericCast(layout.headeropt_rw_offset)
        let layout: ObjCHeaderOptimizationRW32.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}

extension OldObjCOptimization {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        guard layout.headeropt_ro_offset > 0 else {
            return nil
        }
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let offset = cache.fileOffset(
            of: sharedRegionStart + numericCast(offset) + numericCast(layout.headeropt_ro_offset)
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRO64.Layout =  cache.fileHandle.read(offset: offset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        guard layout.headeropt_ro_offset > 0 else {
            return nil
        }
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let offset = cache.fileOffset(
            of: sharedRegionStart + numericCast(offset) + numericCast(layout.headeropt_ro_offset)
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRO32.Layout =  cache.fileHandle.read(offset: offset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}

extension OldObjCOptimization {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO64? {
        guard layout.headeropt_ro_offset > 0 else {
            return nil
        }
        let offset: Int = numericCast(offset) + numericCast(layout.headeropt_ro_offset)
        let layout: ObjCHeaderOptimizationRO64.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO32? {
        guard layout.headeropt_ro_offset > 0 else {
            return nil
        }
        let offset: Int = numericCast(offset) + numericCast(layout.headeropt_ro_offset)
        let layout: ObjCHeaderOptimizationRO32.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}
