//
//  ObjCHeaderOptimizationRO.swift
//
//
//  Created by p-x9 on 2024/10/05
//
//

import Foundation

public protocol ObjCHeaderOptimizationROProtocol {
    associatedtype HeaderInfo: ObjCHeaderInfoROProtocol
    var offset: Int { get }
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

public struct ObjCHeaderOptimizationRO64: LayoutWrapper, ObjCHeaderOptimizationROProtocol {
    public typealias Layout = objc_headeropt_ro_t_64
    public typealias HeaderInfo = ObjCHeaderInfoRO64

    public var layout: Layout
    public let offset: Int

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
        // Warning: HeaderInfo.layoutSize and entrySize are different.
        return AnyRandomAccessCollection(
            cache.fileHandle.readDataSequence<HeaderInfo.Layout>(
                offset: numericCast(offset),
                entrySize: numericCast(layout.entsize),
                numberOfElements: numericCast(layout.count),
                swapHandler: { _ in }
            ).enumerated().map({
                HeaderInfo(
                    layout: $1,
                    offset: offset + entrySize * $0,
                    index: $0
                )
            })
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
        let layouts: MemorySequence<HeaderInfo.Layout> = .init(
            basePointer: cache.ptr
                .advanced(by: offset)
                .assumingMemoryBound(to: HeaderInfo.Layout.self),
            entrySize: numericCast(layout.entsize),
            numberOfElements: numericCast(layout.count)
        )
        return AnyRandomAccessCollection(
            layouts.enumerated()
                .map {
                    HeaderInfo(
                        layout: $1,
                        offset: offset + entrySize * $0,
                        index: $0
                    )
                }
        )
    }
}

public struct ObjCHeaderOptimizationRO32: LayoutWrapper, ObjCHeaderOptimizationROProtocol {
    public typealias Layout = objc_headeropt_ro_t_32
    public typealias HeaderInfo = ObjCHeaderInfoRO32

    public var layout: Layout
    public let offset: Int

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
            cache.fileHandle.readDataSequence<HeaderInfo.Layout>(
                offset: numericCast(offset),
                entrySize: numericCast(layout.entsize),
                numberOfElements: numericCast(layout.count),
                swapHandler: { _ in }
            ).enumerated().map({
                HeaderInfo(
                    layout: $1,
                    offset: offset + entrySize * $0,
                    index: $0
                )
            })
        )
    }

    public func headerInfos(
        in cache: DyldCacheLoaded)
    -> AnyRandomAccessCollection<HeaderInfo> {
        precondition(
            layout.entsize >= HeaderInfo.layoutSize,
            "entsize is smaller than HeaderInfo"
        )
        let offset = offset + layoutSize
        let layouts: MemorySequence<HeaderInfo.Layout> = .init(
            basePointer: cache.ptr
                .advanced(by: offset)
                .assumingMemoryBound(to: HeaderInfo.Layout.self),
            entrySize: numericCast(layout.entsize),
            numberOfElements: numericCast(layout.count)
        )
        return AnyRandomAccessCollection(
            layouts.enumerated()
                .map {
                    HeaderInfo(
                        layout: $1,
                        offset: offset + entrySize * $0,
                        index: $0
                    )
                }
        )
    }
}
