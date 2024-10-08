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
    var count: Int { get }
    var entrySize: Int { get }
    func headerInfos(in cache: DyldCache) -> AnyRandomAccessCollection<HeaderInfo>
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
}

public struct ObjCHeaderInfoRW64: LayoutWrapper {
    public typealias Layout = header_info_rw_64

    public var layout: Layout

    public var isLoaded: Bool { layout.isLoaded == 1 }
    public var isAllClassesRelized: Bool { layout.allClassesRealized == 1 }
}

public struct ObjCHeaderInfoRW32: LayoutWrapper {
    public typealias Layout = header_info_rw_32

    public var layout: Layout

    public var isLoaded: Bool { layout.isLoaded == 1 }
    public var isAllClassesRelized: Bool { layout.allClassesRealized == 1 }
}
