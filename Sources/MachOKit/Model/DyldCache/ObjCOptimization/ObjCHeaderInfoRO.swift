//
//  ObjCHeaderInfoRO.swift
//
//
//  Created by p-x9 on 2024/10/14
//  
//

import Foundation

public protocol ObjCHeaderInfoROProtocol: Sendable {
    associatedtype HeaderOptimizationRO: ObjCHeaderOptimizationROProtocol, LayoutWrapper
    /// offset from start address of main cache
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
    /// Description of an Objective-C image
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: image info
    func imageInfo(in cache: FullDyldCache) -> ObjCImageInfo?

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

    /// Target mach-o image of header
    /// - Parameters:
    ///   - cache: DyldCache to which `self` belongs
    /// - Returns: mach-o file
    ///
    /// target mach-o may be included in one of the subcaches.
    func machO(
        in cache: FullDyldCache
    ) -> MachOFile?
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
        _imageInfo(in: cache)
    }

    public func imageInfo(in cache: DyldCacheLoaded) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        return cache.ptr
            .advanced(by: numericCast(offset))
            .autoBoundPointee()
    }

    public func imageInfo(in cache: FullDyldCache) -> ObjCImageInfo? {
        _imageInfo(in: cache)
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

    public func machO(
        in cache: FullDyldCache
    ) -> MachOFile? {
        _machO(
            in: cache
        )
    }
}

extension ObjCHeaderInfoRO64 {
    internal func _imageInfo<Cache: _DyldCacheFileRepresentable>(in cache: Cache) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(offset)
        guard let fileOffset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        return cache.fileHandle.read(offset: fileOffset)
    }

    internal func _machO(
        in cache: DyldCache
    ) -> MachOFile? {
        guard let offset = resolvedMachOHeaderOffset(in: cache) else {
            return nil
        }
        let imagePath = imagePath(in: cache)
        return try? .init(
            url: cache.url,
            imagePath: imagePath,
            headerStartOffsetInCache: numericCast(offset),
            cache: cache
        )
    }

    internal func _machO(
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

    internal func _machO(
        in cache: FullDyldCache
    ) -> MachOFile? {
        guard let offset = resolvedMachOHeaderOffset(in: cache),
              let (url, segment) = cache.urlAndFileSegment(forOffset: offset) else {
            return nil
        }
        let imagePath = imagePath(in: cache)

        let _cache: DyldCache = .init(
            unsafeFileHandle: segment._file,
            url: url,
            cpu: cache.cpu,
            mainCache: segment.offset == 0 ? nil : cache.mainCache
        )
        _cache._fullCache = cache

        return try? .init(
            url: url,
            imagePath: imagePath,
            headerStartOffsetInCache: numericCast(offset) - segment.offset,
            cache: _cache
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
        _imageInfo(in: cache)
    }

    public func imageInfo(in cache: DyldCacheLoaded) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        return cache.ptr
            .advanced(by: numericCast(offset))
            .autoBoundPointee()
    }

    public func imageInfo(in cache: FullDyldCache) -> ObjCImageInfo? {
        _imageInfo(in: cache)
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

    public func machO(
        in cache: FullDyldCache
    ) -> MachOFile? {
        _machO(
            in: cache
        )
    }
}

extension ObjCHeaderInfoRO32 {
    internal func _imageInfo<Cache: _DyldCacheFileRepresentable>(in cache: Cache) -> ObjCImageInfo? {
        let offset = offset + layoutOffset(of: \.info_offset) + numericCast(layout.info_offset)
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(offset)
        guard let fileOffset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        return cache.fileHandle.read(offset: fileOffset)
    }

    internal func _machO(
        in cache: DyldCache
    ) -> MachOFile? {
        guard let offset = resolvedMachOHeaderOffset(in: cache) else {
            return nil
        }
        let imagePath = imagePath(in: cache)
        return try? .init(
            url: cache.url,
            imagePath: imagePath,
            headerStartOffsetInCache: numericCast(offset),
            cache: cache
        )
    }

    internal func _machO(
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

    internal func _machO(
        in cache: FullDyldCache
    ) -> MachOFile? {
        guard let offset = resolvedMachOHeaderOffset(in: cache),
              let (url, segment) = cache.urlAndFileSegment(forOffset: offset) else {
            return nil
        }
        let imagePath = imagePath(in: cache)

        let _cache: DyldCache = .init(
            unsafeFileHandle: segment._file,
            url: url,
            cpu: cache.cpu,
            mainCache: segment.offset == 0 ? nil : cache.mainCache
        )
        _cache._fullCache = cache

        return try? .init(
            url: url,
            imagePath: imagePath,
            headerStartOffsetInCache: numericCast(offset) - segment.offset,
            cache: _cache
        )
    }
}

extension ObjCHeaderInfoROProtocol {
    internal func resolvedMachOHeaderOffset<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> UInt64? {
        let offset = offset + machOHeaderOffset
        // Check if the cache file contains offset
        // objc header info is exsisted only in main dyld cache
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(offset)
        guard let fileOffset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        return fileOffset
    }

    internal func imagePath(
        in cache: DyldCache
    ) -> String? {
        let effectiveDyldCache: DyldCache
        let imageInfos: DataSequence<DyldCacheImageInfo>

        if let mainCache = cache.mainCache,
           let mainCacheImageInfos = mainCache.imageInfos {
            effectiveDyldCache = mainCache
            imageInfos = mainCacheImageInfos
        } else if let currentCacheImageInfos = cache.imageInfos {
            effectiveDyldCache = cache
            imageInfos = currentCacheImageInfos
        } else {
            return nil
        }

        let offset = offset + machOHeaderOffset
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(offset)
        guard let imageInfo = imageInfos.first(
                where: {
                    $0.address == address
                }
              ) else {
            return nil
        }
        return imageInfo._path(in: effectiveDyldCache)
    }

    internal func imagePath(
        in cache: FullDyldCache
    ) -> String? {
        let offset = offset + machOHeaderOffset
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(offset)
        guard let imageInfos = cache.imageInfos,
              let imageInfo = imageInfos.first(
                where: {
                    $0.address == address
                }
              ) else {
            return nil
        }
        return imageInfo._path(in: cache)
    }
}
