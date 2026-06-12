//
//  FullDyldCache.swift
//  MachOKit
//
//  Created by p-x9 on 2025/07/13
//
//

import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
internal import FileIOBinary
#else
@_implementationOnly import FileIO
@_implementationOnly import FileIOBinary
#endif

/// `FullDyldCache` is a high-level abstraction that represents a complete dyld shared cache
/// composed of a main cache file and all its associated subcaches.
///
/// It allows unified access to Mach-O files and metadata across all cache segments,
/// combining them into a single virtual view. This class is useful for analyzing
/// or extracting information from the entire dyld shared cache as if it were a single file.
///
/// - Important: The ``FullDyldCache`` requires the path to the main cache file.
///   It automatically detects and opens all related subcache files.
///
/// - SeeAlso: ``DyldCache``, ``DyldCacheRepresentable``
public class FullDyldCache: DyldCacheRepresentable, _DyldCacheFileRepresentable {
    typealias File = ConcatenatedMemoryMappedFile

    /// URL of loaded dyld cache file
    public let url: URL
    let fileHandle: File

    // Retain the symbol cache
    private var _symbolCache: DyldCache?

    public var headerSize: Int {
        header.actualSize
    }

    /// Header for dyld cache
    public let header: DyldCacheHeader

    /// Target CPU info.
    ///
    /// It is obtained based on magic.
    public let cpu: CPU

    public let subCacheSuffixes: [String]

    /// URLs of the main cache file and all its subcache files
    public let urls: [URL]

    // Headers of sub caches, preloaded to avoid re-reading them
    // every time a `DyldCache` is assembled
    internal let subCacheHeaders: [DyldCacheHeader]

    public init(url: URL) throws {
        self.url = url

        let mainCache = try DyldCache(url: url)

        let subCacheSuffixes = mainCache.subCaches?.map {
            $0.fileSuffix
        } ?? []
        var urls = [url]
        urls += subCacheSuffixes.map {
            URL(fileURLWithPath: url.path + $0, isDirectory: false)
        }

        let fileHandle: File = try .open(
            urls: urls,
            isWritable: false
        )
        self.fileHandle = fileHandle
        self.header = mainCache.header
        self.cpu = mainCache.cpu
        self.subCacheSuffixes = subCacheSuffixes
        self.subCacheHeaders = try fileHandle._files[1...].map {
            try $0._file.read(offset: 0)
        }
        self.urls = urls
    }
}

extension FullDyldCache {
    /// Header for main dyld cache
    /// When this dyld cache is a subcache, represent the header of the main cache
    public var mainCacheHeader: DyldCacheHeader { header }
}

extension FullDyldCache {
    public var mainCache: DyldCache {
        let cache: DyldCache = .init(
            unsafeFileHandle: fileHandle._files[0]._file,
            url: url,
            cpu: cpu,
            header: header,
            mainCache: nil
        )
        cache._fullCache = self
        cache._symbolCache = _symbolCache
        return cache
    }

    public var subCaches: [DyldCache] {
        let mainCache = self.mainCache
        return (1..<fileHandle._files.count).map {
            cache(atIndex: $0, mainCache: mainCache)
        }
    }

    public var allCaches: [DyldCache] {
        [mainCache] + subCaches
    }
}

extension FullDyldCache {
    /// Sequence of mapping infos
    public var mappingInfos: [DyldCacheMappingInfo]? {
        zip(fileHandle._files, allCaches).compactMap { file, cache in
            cache.mappingInfos?
                .map {
                    $0.withFileOffset(
                        $0.fileOffset + numericCast(file.offset)
                    )
                }
        }.flatMap { $0 }
    }

    /// Sequence of mapping and slide infos
    public var mappingAndSlideInfos: [DyldCacheMappingAndSlideInfo]? {
        zip(fileHandle._files, allCaches).compactMap { file, cache in
            cache.mappingAndSlideInfos?
                .map {
                    $0.withFileOffset(
                        $0.fileOffset + numericCast(file.offset)
                    )
                    .withSlideInfoFileOffset(
                        $0.slideInfoFileOffset + numericCast(file.offset)
                    )
                }
        }.flatMap { $0 }
    }

    /// Sequence of image infos.
    public var imageInfos: DataSequence<DyldCacheImageInfo>? {
        mainCache.imageInfos
    }

    /// Sequence of image text infos.
    public var imageTextInfos: DataSequence<DyldCacheImageTextInfo>? {
        mainCache.imageTextInfos
    }

    /// Sub cache type
    ///
    /// Check if entry type is `dyld_subcache_entry_v1` or `dyld_subcache_entry`
    public var subCacheEntryType: DyldSubCacheEntryType? {
        mainCache.subCacheEntryType
    }

    // Sequence of sub caches
    public typealias SubCaches = DyldCache.SubCaches
    @_implements(DyldCacheRepresentable, subCaches)
    public var _subCaches: SubCaches? {
        mainCache.subCaches
    }

    /// DyldCache containing unmapped local symbols
    public var symbolCache: DyldCache? {
        get throws {
            if let _symbolCache = _symbolCache { return _symbolCache }
            let symbolCache = try mainCache.symbolCache
            _symbolCache = symbolCache
            return symbolCache
        }
    }

    /// Local symbol info
    public var localSymbolsInfo: DyldCacheLocalSymbolsInfo? {
        zip(allCaches, fileHandle._files)
            .lazy
            .compactMap { cache, file in
                var info = cache.localSymbolsInfo
                info?.offset += file.offset
                return info
            }
            .first
    }
}

extension FullDyldCache {
    /// Sequence of MachO information contained in this cache
    public func machOFiles() -> AnySequence<MachOFile> {
        guard let imageInfos else { return AnySequence([]) }
        let mainCache = self.mainCache
        let machOFiles = imageInfos
            .lazy
            .compactMap { info in
                guard let fileOffset = self.fileOffset(of: info.address),
                      let imagePath = info.path(in: self) else {
                    return nil
                }
                return (imagePath, fileOffset)
            }
            .compactMap { (imagePath: String, fileOffset: UInt64) ->
                MachOFile? in
                guard let index = self.fileIndex(forOffset: fileOffset) else {
                    return nil
                }
                let cache = self.cache(atIndex: index, mainCache: mainCache)
                let segment = self.fileHandle._files[index]
                return try? .init(
                    url: cache.url,
                    imagePath: imagePath,
                    headerStartOffsetInCache: numericCast(fileOffset) - segment.offset,
                    cache: cache
                )
            }

        return AnySequence(machOFiles)
    }

    public var dyld: MachOFile? {
        guard let fileOffset = fileOffset(of: header.dyldInCacheMH) else {
            return nil
        }
        guard let (cache, segment) = cacheAndFileSegment(forOffset: fileOffset) else {
            return nil
        }
        return try? MachOFile(
            url: cache.url,
            imagePath: "/usr/lib/dyld",
            headerStartOffsetInCache: numericCast(fileOffset) - segment.offset,
            cache: cache
        )
    }
}

extension FullDyldCache {
    /// File offset after rebasing performed on the specified file offset
    /// - Parameter offset: target file offset
    /// - Returns: rebased file offset
    ///
    /// [dyld Implementation](https://github.com/apple-oss-distributions/dyld/blob/66c652a1f1f6b7b5266b8bbfd51cb0965d67cc44/common/MetadataVisitor.cpp#L265)
    public func resolveRebase(at offset: UInt64) -> UInt64? {
        guard let (cache, localOffset) = cacheAndLocalOffset(forOffset: offset) else {
            return nil
        }
        return cache.resolveRebase(at: localOffset)
    }

    /// File offset after optional rebasing performed on the specified file offset
    /// - Parameter offset: target file offset
    /// - Returns: optional rebased file offset
    ///
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/66c652a1f1f6b7b5266b8bbfd51cb0965d67cc44/common/MetadataVisitor.cpp#L435)
    /// `resolveOptionalRebase` differs from `resolveRebase` in that rebasing may or may not actually take place.
    public func resolveOptionalRebase(at offset: UInt64) -> UInt64? {
        guard let (cache, localOffset) = cacheAndLocalOffset(forOffset: offset) else {
            return nil
        }
        return cache.resolveOptionalRebase(at: localOffset)
    }

    /// The subcache that maps `offset`, paired with `offset` translated into
    /// that subcache's own coordinate space.
    ///
    /// `cache(forOffset:)` builds the subcache's `DyldCache` from that file's
    /// standalone mmap, so its mapping table is addressed from the start of
    /// the subcache file. `DyldCache.resolveRebase` / `resolveOptionalRebase`
    /// consult that table via `mappingAndSlideInfo(forFileOffset:)` and read
    /// bytes through the subcache's own file handle, so they must be given a
    /// subcache-local offset — the full-cache `offset` minus the subcache's
    /// start within the full cache. This mirrors the `- segment.offset`
    /// adjustment already applied in `machOFiles()`; without it the lookup
    /// always misses for any pointer outside the first subcache.
    private func cacheAndLocalOffset(forOffset offset: UInt64) -> (DyldCache, UInt64)? {
        guard let (cache, segment) = cacheAndFileSegment(forOffset: offset) else {
            return nil
        }
        return (cache, offset - numericCast(segment.offset))
    }
}

extension FullDyldCache {
    public func url(forOffset offset: UInt64) -> URL? {
        guard let index = fileIndex(forOffset: offset) else { return nil }
        return urls[index]
    }

    internal func fileSegment(forOffset offset: UInt64) -> File.FileSegment? {
        try? fileHandle._file(for: numericCast(offset))
    }

    internal func urlAndFileSegment(forOffset offset: UInt64) -> (URL, File.FileSegment)? {
        guard let index = fileIndex(forOffset: offset) else { return nil }
        return (urls[index], fileHandle._files[index])
    }

    internal func cacheAndFileSegment(forOffset offset: UInt64) -> (DyldCache, File.FileSegment)? {
        guard let index = fileIndex(forOffset: offset) else { return nil }
        return (cache(atIndex: index), fileHandle._files[index])
    }

    private func fileIndex(forOffset offset: UInt64) -> Int? {
        fileHandle._files.firstIndex(
            where: {
                $0.offset <= offset && offset < $0.offset + $0.size
            }
        )
    }

    public func cache(forOffset offset: UInt64) -> DyldCache? {
        guard let index = fileIndex(forOffset: offset) else { return nil }
        return cache(atIndex: index)
    }

    public func cache(for url: URL) -> DyldCache? {
        guard let index = urls.firstIndex(of: url) else { return nil }
        return cache(atIndex: index)
    }
}

extension FullDyldCache {
    /// Assemble the `DyldCache` for the file at `index` from the
    /// preloaded header, without re-reading it from the file
    internal func cache(
        atIndex index: Int,
        mainCache: DyldCache? = nil
    ) -> DyldCache {
        if index == 0 { return mainCache ?? self.mainCache }
        let cache: DyldCache = .init(
            unsafeFileHandle: fileHandle._files[index]._file,
            url: urls[index],
            cpu: cpu,
            header: subCacheHeaders[index - 1],
            mainCache: mainCache ?? self.mainCache
        )
        cache._fullCache = self
        return cache
    }
}
