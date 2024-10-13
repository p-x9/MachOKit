//
//  ObjCHeaderOptimizationRW.swift
//
//
//  Created by p-x9 on 2024/10/05
//
//

import Foundation

public protocol ObjCHeaderOptimizationRWProtocol {
    associatedtype HeaderInfo: LayoutWrapper
    /// number of header infos
    var count: Int { get }
    /// layout size of header info
    var entrySize: Int { get }
    /// Sequence of header infos
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header infos
    func headerInfos(in cache: DyldCache) -> AnyRandomAccessCollection<HeaderInfo>
    /// Sequence of header infos
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header infos
    func headerInfos(in cache: DyldCacheLoaded) -> AnyRandomAccessCollection<HeaderInfo>
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
    ) -> AnyRandomAccessCollection<HeaderInfo> {
        precondition(
            layout.entsize >= HeaderInfo.layoutSize,
            "entsize is smaller than HeaderInfo"
        )
        let offset = offset + layoutSize
        return AnyRandomAccessCollection(
            cache.fileHandle.readDataSequence(
                offset: numericCast(offset),
                entrySize: numericCast(layout.entsize),
                numberOfElements: numericCast(layout.count)
            )
        )
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
    ) -> AnyRandomAccessCollection<HeaderInfo> {
        precondition(
            layout.entsize >= HeaderInfo.layoutSize,
            "entsize is smaller than HeaderInfo"
        )
        let offset = offset + layoutSize
        return AnyRandomAccessCollection(
            cache.fileHandle.readDataSequence(
                offset: numericCast(offset),
                entrySize: numericCast(layout.entsize),
                numberOfElements: numericCast(layout.count)
            )
        )
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
}
