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

    /// offset to mach-o header from start of self
    var machOHeaderOffset: Int { get }

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
    ///   - cache: DyldCache to which `self` belongs
    /// - Returns: mach-o file
    ///
    /// target mach-o may be included in one of the subcaches.
    func machO(
        in cache: DyldCache
    ) -> MachOFile?

    /// Target mach-o image of header
    /// - Parameters:
    ///   - cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: mach-o file
    func machO(
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

    public var machOHeaderOffset: Int {
        numericCast(layout.mhdr_offset)
    }

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
        in cache: DyldCache
    ) -> MachOFile? {
        _machO(
            in: cache
        )
    }

    public func machO(
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        _machO(
            in: cache
        )
    }

    private func _machO(
        in cache: DyldCache
    ) -> MachOFile? {
        let offset = offset + machOHeaderOffset
        // Check if the cache file contains offset
        // objc header info is exsisted only in main dyld cache
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(offset)
        guard let fileOffset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        return try? .init(
            url: cache.url,
            imagePath: "", // FIXME: path
            headerStartOffsetInCache: numericCast(fileOffset)
        )
    }

    private func _machO(
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        let ptr = cache.ptr
            .advanced(by: offset)
            .advanced(by: numericCast(layout.mhdr_offset))
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

    public var machOHeaderOffset: Int {
        numericCast(layout.mhdr_offset)
    }

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
        in cache: DyldCache
    ) -> MachOFile? {
        _machO(
            in: cache
        )
    }

    public func machO(
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        _machO(
            in: cache
        )
    }

    private func _machO(
        in cache: DyldCache
    ) -> MachOFile? {
        let offset = offset + machOHeaderOffset
        // Check if the cache file contains offset
        // objc header info is exsisted only in main dyld cache
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(offset)
        guard let fileOffset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        return try? .init(
            url: cache.url,
            imagePath: "", // FIXME: path
            headerStartOffsetInCache: numericCast(fileOffset)
        )
    }

    private func _machO(
        in cache: DyldCacheLoaded
    ) -> MachOImage? {
        let ptr = cache.ptr
            .advanced(by: offset)
            .advanced(by: numericCast(layout.mhdr_offset))
        return .init(
            ptr: ptr
                .assumingMemoryBound(to: mach_header.self)
        )
    }
}
