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
    func headerInfos(in cache: DyldCache) -> DataSequence<HeaderInfo>
}

public struct ObjCHeaderOptimizationRW64: LayoutWrapper, ObjCHeaderOptimizationRWProtocol {
    public typealias Layout = objc_headeropt_rw_t_64
    public typealias HeaderInfo = ObjCHeaderInfoRW64

    public var layout: Layout
    public var offset: Int

    public func headerInfos(in cache: DyldCache) -> DataSequence<HeaderInfo> {
        let offset = offset + layoutSize
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: numericCast(layout.count)
        )
    }
}

public struct ObjCHeaderOptimizationRW32: LayoutWrapper, ObjCHeaderOptimizationRWProtocol {
    public typealias Layout = objc_headeropt_rw_t_32
    public typealias HeaderInfo = ObjCHeaderInfoRW32

    public var layout: Layout
    public var offset: Int

    public func headerInfos(in cache: DyldCache) -> DataSequence<HeaderInfo> {
        let offset = offset + layoutSize
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: numericCast(layout.count)
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
