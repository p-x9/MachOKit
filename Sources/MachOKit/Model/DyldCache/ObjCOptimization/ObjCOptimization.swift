//
//  ObjCOptimization.swift
//
//
//  Created by p-x9 on 2024/05/29
//
//

import Foundation
import MachOKitC

public struct ObjCOptimization: LayoutWrapper, Sendable {
    public typealias Layout = objc_optimization

    public var layout: Layout
}

extension ObjCOptimization {
    public var flags: ObjCOptimizationFlags {
        .init(rawValue: layout.flags)
    }
}

extension ObjCOptimization {
    /// Relative method list selectors are offsets from this address
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: relative selector's base address
    public func relativeMethodSelectorBaseAddress(
        in cache: DyldCacheLoaded
    ) -> UnsafeRawPointer {
        cache.ptr
            .advanced(
                by: numericCast(layout.relativeMethodSelectorBaseAddressOffset)
            )
    }

    /// Relative method list type are offsets from this address
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: relative type's base address
    public func relativeMethodTypeBaseAddress(
        in cache: DyldCacheLoaded
    ) -> UnsafeRawPointer? {
        guard layout.version >= 2 else { return nil }
        let relativeMethodSelectorBaseAddress = relativeMethodSelectorBaseAddress(in: cache)
        return relativeMethodSelectorBaseAddress
            .advanced(
                by: numericCast(layout.relativeMethodSelectorBufferSize)
            )
    }
}

// MARK: Header Optimization RW
// https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/common/DyldSharedCache.cpp#L1892
extension ObjCOptimization {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        _headerOptimizationRW64(in: cache)
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        _headerOptimizationRW32(in: cache)
    }

    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        _headerOptimizationRW64(in: cache)
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        _headerOptimizationRW32(in: cache)
    }
}

extension ObjCOptimization {
    internal func _headerOptimizationRW64<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> ObjCHeaderOptimizationRW64? {
        guard layout.headerInfoRWCacheOffset > 0 else {
            return nil
        }
        let offset: UInt64 = numericCast(layout.headerInfoRWCacheOffset)
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
        in cache: Cache
    ) -> ObjCHeaderOptimizationRW32? {
        guard layout.headerInfoRWCacheOffset > 0 else {
            return nil
        }
        let offset: UInt64 = numericCast(layout.headerInfoRWCacheOffset)
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

extension ObjCOptimization {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW64? {
        guard layout.headerInfoRWCacheOffset > 0 else {
            return nil
        }
        let offset: Int = numericCast(layout.headerInfoRWCacheOffset)
        let layout: ObjCHeaderOptimizationRW64.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: offset
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW32? {
        guard layout.headerInfoRWCacheOffset > 0 else {
            return nil
        }
        let offset: Int = numericCast(layout.headerInfoRWCacheOffset)
        let layout: ObjCHeaderOptimizationRW32.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: offset
        )
    }
}

// MARK: Header Optimization RO
// https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/common/DyldSharedCache.cpp#L2017
extension ObjCOptimization {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        _headerOptimizationRO64(in: cache)
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        _headerOptimizationRO32(in: cache)
    }

    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        _headerOptimizationRO64(in: cache)
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        _headerOptimizationRO32(in: cache)
    }
}

extension ObjCOptimization {
    internal func _headerOptimizationRO64<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> ObjCHeaderOptimizationRO64? {
        guard layout.headerInfoROCacheOffset > 0 else {
            return nil
        }
        let offset: UInt64 = numericCast(layout.headerInfoROCacheOffset)
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
        in cache: Cache
    ) -> ObjCHeaderOptimizationRO32? {
        let offset: UInt64 = numericCast(layout.headerInfoROCacheOffset)
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

extension ObjCOptimization {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO64? {
        guard layout.headerInfoROCacheOffset > 0 else {
            return nil
        }
        let offset: Int = numericCast(layout.headerInfoROCacheOffset)
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
        guard layout.headerInfoROCacheOffset > 0 else {
            return nil
        }
        let offset: Int = numericCast(layout.headerInfoROCacheOffset)
        let layout: ObjCHeaderOptimizationRO32.Layout = cache.ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return .init(
            layout: layout,
            offset: numericCast(offset)
        )
    }
}

// MARK: Hash Tables
// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/DyldSharedCache.cpp#L501
extension ObjCOptimization {
    /// Precomputed selector table
    ///
    /// Returns nil if the table is placed in a subcache that `cache` does not contain.
    /// Use `FullDyldCache` to resolve it across subcaches.
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: selector hash table
    public func selectorHashTable(
        in cache: DyldCache
    ) -> ObjCSelectorHashTable? {
        _selectorHashTable(in: cache)
    }

    /// Precomputed selector table
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: selector hash table
    public func selectorHashTable(
        in cache: FullDyldCache
    ) -> ObjCSelectorHashTable? {
        _selectorHashTable(in: cache)
    }

    /// Precomputed selector table
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: selector hash table
    public func selectorHashTable(
        in cache: DyldCacheLoaded
    ) -> ObjCSelectorHashTable? {
        let offset: Int = numericCast(layout.selectorHashTableCacheOffset)
        guard let layout = cache._objcStringHashTableLayout(at: offset) else {
            return nil
        }
        return .init(layout: layout, offset: offset)
    }
}

extension ObjCOptimization {
    /// Precomputed class table
    ///
    /// Returns nil if the table is placed in a subcache that `cache` does not contain.
    /// Use `FullDyldCache` to resolve it across subcaches.
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: class hash table
    public func classHashTable(
        in cache: DyldCache
    ) -> ObjCClassHashTable? {
        _classHashTable(in: cache)
    }

    /// Precomputed class table
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: class hash table
    public func classHashTable(
        in cache: FullDyldCache
    ) -> ObjCClassHashTable? {
        _classHashTable(in: cache)
    }

    /// Precomputed class table
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: class hash table
    public func classHashTable(
        in cache: DyldCacheLoaded
    ) -> ObjCClassHashTable? {
        let offset: Int = numericCast(layout.classHashTableCacheOffset)
        guard let layout = cache._objcStringHashTableLayout(at: offset) else {
            return nil
        }
        return .init(layout: layout, offset: offset)
    }
}

extension ObjCOptimization {
    /// Precomputed protocol table
    ///
    /// Returns nil if the table is placed in a subcache that `cache` does not contain.
    /// Use `FullDyldCache` to resolve it across subcaches.
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: protocol hash table
    public func protocolHashTable(
        in cache: DyldCache
    ) -> ObjCProtocolHashTable? {
        _protocolHashTable(in: cache)
    }

    /// Precomputed protocol table
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: protocol hash table
    public func protocolHashTable(
        in cache: FullDyldCache
    ) -> ObjCProtocolHashTable? {
        _protocolHashTable(in: cache)
    }

    /// Precomputed protocol table
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: protocol hash table
    public func protocolHashTable(
        in cache: DyldCacheLoaded
    ) -> ObjCProtocolHashTable? {
        let offset: Int = numericCast(layout.protocolHashTableCacheOffset)
        guard let layout = cache._objcStringHashTableLayout(at: offset) else {
            return nil
        }
        return .init(layout: layout, offset: offset)
    }
}

extension ObjCOptimization {
    internal func _selectorHashTable<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> ObjCSelectorHashTable? {
        let offset: Int = numericCast(layout.selectorHashTableCacheOffset)
        guard let layout = cache._objcStringHashTableLayout(at: offset) else {
            return nil
        }
        return .init(layout: layout, offset: offset)
    }

    internal func _classHashTable<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> ObjCClassHashTable? {
        let offset: Int = numericCast(layout.classHashTableCacheOffset)
        guard let layout = cache._objcStringHashTableLayout(at: offset) else {
            return nil
        }
        return .init(layout: layout, offset: offset)
    }

    internal func _protocolHashTable<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> ObjCProtocolHashTable? {
        let offset: Int = numericCast(layout.protocolHashTableCacheOffset)
        guard let layout = cache._objcStringHashTableLayout(at: offset) else {
            return nil
        }
        return .init(layout: layout, offset: offset)
    }
}
