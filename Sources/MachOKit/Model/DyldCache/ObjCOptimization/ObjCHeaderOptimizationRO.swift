//
//  ObjCHeaderOptimizationRO.swift
//
//
//  Created by p-x9 on 2024/10/05
//
//

import Foundation

public protocol ObjCHeaderOptimizationROProtocol {
    associatedtype HeaderInfo: LayoutWrapper
    func headerInfos(in cache: DyldCache) -> AnyRandomAccessCollection<HeaderInfo>
}

public struct ObjCHeaderOptimizationRO64: LayoutWrapper, ObjCHeaderOptimizationROProtocol {
    public typealias Layout = objc_headeropt_ro_t_64
    public typealias HeaderInfo = ObjCHeaderInfoRO64

    public var layout: Layout
    public let offset: Int

    public func headerInfos(in cache: DyldCache) -> AnyRandomAccessCollection<HeaderInfo> {
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
                    offset: offset + HeaderInfo.layoutSize * $0,
                    index: $0
                )
            })
        )
    }
}

public struct ObjCHeaderOptimizationRO32: LayoutWrapper, ObjCHeaderOptimizationROProtocol {
    public typealias Layout = objc_headeropt_ro_t_32
    public typealias HeaderInfo = ObjCHeaderInfoRO32

    public var layout: Layout
    public let offset: Int

    public func headerInfos(in cache: DyldCache) -> AnyRandomAccessCollection<HeaderInfo> {
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
                    offset: offset + HeaderInfo.layoutSize * $0,
                    index: $0
                )
            })
        )
    }
}

public struct ObjCHeaderInfoRO64: LayoutWrapper {
    public typealias Layout = objc_header_info_ro_t_64

    public var layout: Layout
    public let offset: Int
    public let index: Int

    public func imageInfo(in cache: DyldCache) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        return cache.fileHandle.read(offset: numericCast(offset))
    }

    public func machO(
        objcOptimization: ObjCOptimization,
        roOptimizaion: ObjCHeaderOptimizationRO64,
        in cache: DyldCache
    ) -> MachOFile? {
        let offsetFromRoHeader = roOptimizaion.layoutSize + index * numericCast(roOptimizaion.entsize)

        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        let roOffset = objcOptimization.headerInfoROCacheOffset + sharedRegionStart
        let _offset: Int = numericCast(roOffset) + offsetFromRoHeader + numericCast(layout.mhdr_offset)
        guard let offset = cache.fileOffset(
            of: numericCast(_offset)
        ) else {
            return nil
        }
        return try? .init(
            url: cache.url,
            imagePath: "", // FIXME: path
            headerStartOffsetInCache: numericCast(offset)
        )
    }
}

public struct ObjCHeaderInfoRO32: LayoutWrapper {
    public typealias Layout = objc_header_info_ro_t_32

    public var layout: Layout
    public let offset: Int
    public let index: Int

    public func imageInfo(in cache: DyldCache) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        return cache.fileHandle.read(offset: numericCast(offset))
    }

    public func machO(
        objcOptimization: ObjCOptimization,
        roOptimizaion: ObjCHeaderOptimizationRO32,
        in cache: DyldCache
    ) -> MachOFile? {
        let offsetFromRoHeader = roOptimizaion.layoutSize + index * numericCast(roOptimizaion.entsize)

        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        let roOffset = objcOptimization.headerInfoROCacheOffset + sharedRegionStart
        let _offset: Int = numericCast(roOffset) + offsetFromRoHeader + numericCast(layout.mhdr_offset)
        guard let offset = cache.fileOffset(
            of: numericCast(_offset)
        ) else {
            return nil
        }
        return try? .init(
            url: cache.url,
            imagePath: "", // FIXME: path
            headerStartOffsetInCache: numericCast(offset)
        )
    }
}
