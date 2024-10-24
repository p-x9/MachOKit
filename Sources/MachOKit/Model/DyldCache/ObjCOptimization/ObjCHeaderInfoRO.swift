//
//  ObjCHeaderInfoRO.swift
//
//
//  Created by p-x9 on 2024/10/14
//  
//

import Foundation

public protocol ObjCHeaderInfoROProtocol {
    associatedtype HeaderOptimizationRO: ObjCHeaderOptimizationROProtocol, LayoutWrapper
    /// offset from dyld cache starts
    var offset: Int { get }
    /// index of this header info
    var index: Int { get }

    /// Description of an Objective-C image
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: image info
    func imageInfo(in cache: DyldCache) -> ObjCImageInfo?
    /// Description of an Objective-C image
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: image info
    func imageInfo(in cache: DyldCacheLoaded) -> ObjCImageInfo?

    /// Target mach-o image of header
    /// - Parameters:
    ///   - objcOptimization: objc optimization to which `self` belongs
    ///   - roOptimizaion: ro optimization to which `self` belongs
    ///   - cache: DyldCache to which `self` belongs
    /// - Returns: mach-o file
    func machO(
        objcOptimization: ObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCache
    ) -> MachOFile?

    /// Target mach-o image of header
    /// - Parameters:
    ///   - objcOptimization: objc optimization to which `self` belongs
    ///   - roOptimizaion: ro optimization to which `self` belongs
    ///   - cache: DyldCache to which `self` belongs
    /// - Returns: mach-o file
    func machO(
        objcOptimization: OldObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCache
    ) -> MachOFile?

    /// Target mach-o image of header
    /// - Parameters:
    ///   - objcOptimization: objc optimization to which `self` belongs
    ///   - roOptimizaion: ro optimization to which `self` belongs
    ///   - cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: mach-o file
    func machO(
        objcOptimization: ObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCacheLoaded
    ) -> MachOImage?

    /// Target mach-o image of header
    /// - Parameters:
    ///   - objcOptimization: objc optimization to which `self` belongs
    ///   - roOptimizaion: ro optimization to which `self` belongs
    ///   - cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: mach-o file
    func machO(
        objcOptimization: OldObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCacheLoaded
    ) -> MachOImage?
}

// MARK: - ObjCHeaderInfoRO64
public struct ObjCHeaderInfoRO64: LayoutWrapper, ObjCHeaderInfoROProtocol {
    public typealias HeaderOptimizationRO = ObjCHeaderOptimizationRO64
    public typealias Layout = objc_header_info_ro_t_64

    public var layout: Layout
    public let offset: Int
    public let index: Int

    public func imageInfo(in cache: DyldCache) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        return cache.fileHandle.read(offset: numericCast(offset))
    }

    public func imageInfo(in cache: DyldCacheLoaded) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        return cache.ptr
            .advanced(by: numericCast(offset))
            .autoBoundPointee()
    }

    public func machO(
        objcOptimization: ObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCache
    ) -> MachOFile? {
        _machO(
            headerInfoROOffset: objcOptimization.headerInfoROCacheOffset,
            roOptimizaion: roOptimizaion,
            in: cache
        )
    }

    public func machO(
        objcOptimization: OldObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCache
    ) -> MachOFile? {
        _machO(
            headerInfoROOffset: numericCast(objcOptimization.offset) + numericCast(objcOptimization.headeropt_ro_offset),
            roOptimizaion: roOptimizaion,
            in: cache
        )
    }

    public func machO(
        objcOptimization: ObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        _machO(
            headerInfoROOffset: objcOptimization.headerInfoROCacheOffset,
            roOptimizaion: roOptimizaion,
            in: cache
        )
    }

    public func machO(
        objcOptimization: OldObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        _machO(
            headerInfoROOffset: numericCast(objcOptimization.offset) + numericCast(objcOptimization.headeropt_ro_offset),
            roOptimizaion: roOptimizaion,
            in: cache
        )
    }

    private func _machO(
        headerInfoROOffset: UInt64,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCache
    ) -> MachOFile? {
        let offsetFromRoHeader = roOptimizaion.layoutSize + index * roOptimizaion.entrySize

        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        let roOffset = headerInfoROOffset + sharedRegionStart
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

    private func _machO(
        headerInfoROOffset: UInt64,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        guard let slide = cache.slide else { return nil }
        let offsetFromRoHeader = roOptimizaion.layoutSize + index * roOptimizaion.entrySize

        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        let roOffset = headerInfoROOffset + sharedRegionStart + numericCast(slide)
        let _offset: Int = numericCast(roOffset) + offsetFromRoHeader + numericCast(layout.mhdr_offset)
        guard let ptr = UnsafeRawPointer(bitPattern: _offset) else {
            return nil
        }
        return .init(
            ptr: ptr
                .assumingMemoryBound(to: mach_header.self)
        )
    }
}

// MARK: - ObjCHeaderInfoRO32
public struct ObjCHeaderInfoRO32: LayoutWrapper, ObjCHeaderInfoROProtocol {
    public typealias HeaderOptimizationRO = ObjCHeaderOptimizationRO32
    public typealias Layout = objc_header_info_ro_t_32

    public var layout: Layout
    public let offset: Int
    public let index: Int

    public func imageInfo(in cache: DyldCache) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        return cache.fileHandle.read(offset: numericCast(offset))
    }

    public func imageInfo(in cache: DyldCacheLoaded) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        return cache.ptr
            .advanced(by: numericCast(offset))
            .autoBoundPointee()
    }

    public func machO(
        objcOptimization: ObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCache
    ) -> MachOFile? {
        _machO(
            headerInfoROOffset: objcOptimization.headerInfoROCacheOffset,
            roOptimizaion: roOptimizaion,
            in: cache
        )
    }

    public func machO(
        objcOptimization: OldObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCache
    ) -> MachOFile? {
        _machO(
            headerInfoROOffset: numericCast(objcOptimization.offset) + numericCast(objcOptimization.headeropt_ro_offset),
            roOptimizaion: roOptimizaion,
            in: cache
        )
    }

    public func machO(
        objcOptimization: ObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        _machO(
            headerInfoROOffset: objcOptimization.headerInfoROCacheOffset,
            roOptimizaion: roOptimizaion,
            in: cache
        )
    }

    public func machO(
        objcOptimization: OldObjCOptimization,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        _machO(
            headerInfoROOffset: numericCast(objcOptimization.offset) + numericCast(objcOptimization.headeropt_ro_offset),
            roOptimizaion: roOptimizaion,
            in: cache
        )
    }

    private func _machO(
        headerInfoROOffset: UInt64,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCache
    ) -> MachOFile? {
        let offsetFromRoHeader = roOptimizaion.layoutSize + index * numericCast(roOptimizaion.entsize)

        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        let roOffset = headerInfoROOffset + sharedRegionStart
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

    private func _machO(
        headerInfoROOffset: UInt64,
        roOptimizaion: HeaderOptimizationRO,
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        guard let slide = cache.slide else { return nil }
        let offsetFromRoHeader = roOptimizaion.layoutSize + index * numericCast(roOptimizaion.entsize)

        let sharedRegionStart = cache.mainCacheHeader.sharedRegionStart
        let roOffset = headerInfoROOffset + sharedRegionStart + numericCast(slide)
        let _offset: Int = numericCast(roOffset) + offsetFromRoHeader + numericCast(layout.mhdr_offset)
        guard let ptr = UnsafeRawPointer(bitPattern: _offset) else {
            return nil
        }
        return .init(
            ptr: ptr
                .assumingMemoryBound(to: mach_header.self)
        )
    }
}
