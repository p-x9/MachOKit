//
//  ObjCHeaderOptimizationRW.swift
//
//
//  Created by p-x9 on 2024/10/05
//
//

import Foundation

public protocol ObjCHeaderOptimizationRWProtocol {
    associatedtype HeaderInfo: ObjCHeaderInfoRWProtocol
    /// offset from start address of main cache
    var offset: Int { get }
    /// number of header infos
    var count: Int { get }
    /// layout size of header info
    var entrySize: Int { get }
    /// Sequence of header infos
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header infos
    func headerInfos(in cache: DyldCache) -> AnyRandomAccessCollection<HeaderInfo>?
    /// Sequence of header infos
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header infos
    func headerInfos(in cache: DyldCacheLoaded) -> AnyRandomAccessCollection<HeaderInfo>
    /// Sequence of header infos
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header infos
    func headerInfos(in cache: FullDyldCache) -> AnyRandomAccessCollection<HeaderInfo>?
}

public struct ObjCHeaderOptimizationRW64: LayoutWrapper, ObjCHeaderOptimizationRWProtocol {
    public typealias Layout = objc_headeropt_rw_t_64
    public typealias HeaderInfo = ObjCHeaderInfoRW64

    public var layout: Layout
    public var offset: Int

    public var count: Int { numericCast(layout.count) }
    public var entrySize: Int { numericCast(layout.entsize) }

    public func headerInfos(
        in cache: DyldCache
    ) -> AnyRandomAccessCollection<HeaderInfo>? {
        _headerInfos(in: cache)
    }

    public func headerInfos(
        in cache: DyldCacheLoaded
    ) -> AnyRandomAccessCollection<HeaderInfo> {
        precondition(
            layout.entsize >= HeaderInfo.layoutSize,
            "entsize is smaller than HeaderInfo"
        )
        let offset = offset + layoutSize
        return AnyRandomAccessCollection(
            MemorySequence(
                basePointer: cache.ptr
                    .advanced(by: numericCast(offset))
                    .assumingMemoryBound(to: HeaderInfo.self),
                entrySize: numericCast(layout.entsize),
                numberOfElements: numericCast(layout.count)
            )
        )
    }

    public func headerInfos(
        in cache: FullDyldCache
    ) -> AnyRandomAccessCollection<HeaderInfo>? {
        _headerInfos(in: cache)
    }
}

extension ObjCHeaderOptimizationRW64 {
    internal func _headerInfos<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> AnyRandomAccessCollection<HeaderInfo>? {
        precondition(
            layout.entsize >= HeaderInfo.layoutSize,
            "entsize is smaller than HeaderInfo"
        )
        let offset: UInt64 = numericCast(offset + layoutSize)
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let resolvedOffset = cache.fileOffset(
            of: sharedRegionStart + offset
        ) else {
            return nil
        }
        return AnyRandomAccessCollection(
            cache.fileHandle.readDataSequence(
                offset: resolvedOffset,
                entrySize: entrySize,
                numberOfElements: count
            )
        )
    }
}

public struct ObjCHeaderOptimizationRW32: LayoutWrapper, ObjCHeaderOptimizationRWProtocol {
    public typealias Layout = objc_headeropt_rw_t_32
    public typealias HeaderInfo = ObjCHeaderInfoRW32

    public var layout: Layout
    public var offset: Int

    public var count: Int { numericCast(layout.count) }
    public var entrySize: Int { numericCast(layout.entsize) }

    public func headerInfos(
        in cache: DyldCache
    ) -> AnyRandomAccessCollection<HeaderInfo>? {
        _headerInfos(in: cache)
    }

    public func headerInfos(
        in cache: DyldCacheLoaded
    ) -> AnyRandomAccessCollection<HeaderInfo> {
        precondition(
            layout.entsize >= HeaderInfo.layoutSize,
            "entsize is smaller than HeaderInfo"
        )
        let offset = offset + layoutSize
        return AnyRandomAccessCollection(
            MemorySequence(
                basePointer: cache.ptr
                    .advanced(by: numericCast(offset))
                    .assumingMemoryBound(to: HeaderInfo.self),
                entrySize: numericCast(layout.entsize),
                numberOfElements: numericCast(layout.count)
            )
        )
    }

    public func headerInfos(
        in cache: FullDyldCache
    ) -> AnyRandomAccessCollection<HeaderInfo>? {
        _headerInfos(in: cache)
    }
}

extension ObjCHeaderOptimizationRW32 {
    internal func _headerInfos<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> AnyRandomAccessCollection<HeaderInfo>? {
        precondition(
            layout.entsize >= HeaderInfo.layoutSize,
            "entsize is smaller than HeaderInfo"
        )
        let offset: UInt64 = numericCast(offset + layoutSize)
        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        guard let resolvedOffset = cache.fileOffset(
            of: sharedRegionStart + offset
        ) else {
            return nil
        }
        return AnyRandomAccessCollection(
            cache.fileHandle.readDataSequence(
                offset: resolvedOffset,
                entrySize: entrySize,
                numberOfElements: count
            )
        )
    }
}
