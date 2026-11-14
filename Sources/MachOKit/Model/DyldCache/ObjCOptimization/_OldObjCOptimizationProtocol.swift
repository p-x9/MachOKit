//
//  _OldObjCOptimizationProtocol.swift
//  MachOKit
//
//  Created by p-x9 on 2026/01/25
//  
//

import Foundation
import MachOKitC

protocol _OldObjCOptimizationProtocol {
    var offset: Int { get }
}

extension OldObjCOptimization12: _OldObjCOptimizationProtocol {}
extension OldObjCOptimization13: _OldObjCOptimizationProtocol {}
extension OldObjCOptimization15: _OldObjCOptimizationProtocol {}
extension OldObjCOptimization16: _OldObjCOptimizationProtocol {}

// MARK: - RW

extension _OldObjCOptimizationProtocol {
    internal func _headerOptimizationRW64<Cache: _DyldCacheFileRepresentable>(
        rwOffset: Int,
        in cache: Cache
    ) -> ObjCHeaderOptimizationRW64? {
        guard rwOffset > 0 else {
            return nil
        }
        let offset: UInt64 = numericCast(offset) + numericCast(rwOffset)
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let resolvedOffset = cache.fileOffset(
            of: sharedRegionStart + offset
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRW64.Layout = cache.fileHandle.read(offset: resolvedOffset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    internal func _headerOptimizationRW32<Cache: _DyldCacheFileRepresentable>(
        rwOffset: Int,
        in cache: Cache
    ) -> ObjCHeaderOptimizationRW32? {
        guard rwOffset > 0 else {
            return nil
        }
        let offset: UInt64 = numericCast(offset) + numericCast(rwOffset)
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let resolvedOffset = cache.fileOffset(
            of: sharedRegionStart + offset
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRW32.Layout = cache.fileHandle.read(offset: resolvedOffset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}

extension _OldObjCOptimizationProtocol {
    internal func _headerOptimizationRW64(
        rwOffset: Int,
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW64? {
        guard rwOffset > 0 else {
            return nil
        }
        let offset: Int = numericCast(offset) + numericCast(rwOffset)
        let layout: ObjCHeaderOptimizationRW64.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    internal func _headerOptimizationRW32(
        rwOffset: Int,
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW32? {
        guard rwOffset > 0 else {
            return nil
        }
        let offset: Int = numericCast(offset) + numericCast(rwOffset)
        let layout: ObjCHeaderOptimizationRW32.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}

// MARK: - RO

extension _OldObjCOptimizationProtocol {
    internal func _headerOptimizationRO64<Cache: _DyldCacheFileRepresentable>(
        roOffset: Int,
        in cache: Cache
    ) -> ObjCHeaderOptimizationRO64? {
        guard roOffset > 0 else {
            return nil
        }
        let offset: UInt64 = numericCast(offset) + numericCast(roOffset)
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let resolvedOffset = cache.fileOffset(
            of: sharedRegionStart + offset
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRO64.Layout = cache.fileHandle.read(offset: resolvedOffset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    internal func _headerOptimizationRO32<Cache: _DyldCacheFileRepresentable>(
        roOffset: Int,
        in cache: Cache
    ) -> ObjCHeaderOptimizationRO32? {
        guard roOffset > 0 else {
            return nil
        }
        let offset: UInt64 = numericCast(offset) + numericCast(roOffset)
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let resolvedOffset = cache.fileOffset(
            of: sharedRegionStart + offset
        ) else {
            return nil
        }
        let layout: ObjCHeaderOptimizationRO32.Layout = cache.fileHandle.read(offset: resolvedOffset)
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}

extension _OldObjCOptimizationProtocol {
    internal func _headerOptimizationRO64(
        roOffset: Int,
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO64? {
        guard roOffset > 0 else {
            return nil
        }
        let offset: Int = numericCast(offset) + numericCast(roOffset)
        let layout: ObjCHeaderOptimizationRO64.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }

    internal func _headerOptimizationRO32(
        roOffset: Int,
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO32? {
        guard roOffset > 0 else {
            return nil
        }
        let offset: Int = numericCast(offset) + numericCast(roOffset)
        let layout: ObjCHeaderOptimizationRO32.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}

// MARK: - Hash Tables

extension _OldObjCOptimizationProtocol {
    /// Offsets in `objc_opt_t` are relative to `objc_opt_t` itself.
    /// - Parameter fieldOffset: offset from start of `objc_opt_t`
    /// - Returns: offset from start address of main cache
    internal func _hashTableOffset(_ fieldOffset: Int32) -> Int? {
        guard fieldOffset != 0 else { return nil }
        return offset + numericCast(fieldOffset)
    }

    internal func _oldHashTable<Table: _OldObjCStringHashTable, Cache: _DyldCacheFileRepresentable>(
        fieldOffset: Int32,
        version: UInt32,
        in cache: Cache
    ) -> Table? {
        guard let offset = _hashTableOffset(fieldOffset),
              let layout: objc_stringhash_t = cache._objcHashTableLayout(at: offset) else {
            return nil
        }
        return .init(layout: layout, offset: offset, optimizationVersion: numericCast(version))
    }

    internal func _oldHashTable<Table: _OldObjCStringHashTable>(
        fieldOffset: Int32,
        version: UInt32,
        in cache: DyldCacheLoaded
    ) -> Table? {
        guard let offset = _hashTableOffset(fieldOffset),
              let layout: objc_stringhash_t = cache._objcHashTableLayout(at: offset) else {
            return nil
        }
        return .init(layout: layout, offset: offset, optimizationVersion: numericCast(version))
    }
}
