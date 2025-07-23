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
#else
@_implementationOnly import FileIO
#endif

public class FullDyldCache: DyldCacheRepresentable, _DyldCacheFileRepresentable {
    typealias File = ConcatenatedMemoryMappedFile

    /// URL of loaded dyld cache file
    public let url: URL
    let fileHandle: File

    public var headerSize: Int {
        header.actualSize
    }

    /// Header for dyld cache
    public let header: DyldCacheHeader

    /// Target CPU info.
    ///
    /// It is obtained based on magic.
    public let cpu: CPU

    public var subCacheSuffixes: [String]

    public init(url: URL) throws {
        self.url = url

        let mainCache = try DyldCache(url: url)

        let subCacheSuffixes = mainCache.subCaches?.map {
            $0.fileSuffix
        } ?? []
        var urls = [url]
        urls += subCacheSuffixes.map {
            URL(fileURLWithPath: url.path + $0)
        }

        self.fileHandle = try .open(
            urls: urls,
            isWritable: false
        )
        self.header = mainCache.header
        self.cpu = mainCache.cpu
        self.subCacheSuffixes = subCacheSuffixes
    }
}

extension FullDyldCache {
    /// Header for main dyld cache
    /// When this dyld cache is a subcache, represent the header of the main cache
    public var mainCacheHeader: DyldCacheHeader { header }
}

extension FullDyldCache {
    public var urls: [URL] {
        [url] + subCacheSuffixes.map {
            URL(fileURLWithPath: url.path + $0)
        }
    }
}

extension FullDyldCache {
    public var mainCache: DyldCache {
        .init(
            unsafeFileHandle: fileHandle._files[0]._file,
            url: url,
            cpu: cpu,
            mainCacheHeader: nil
        )
    }

    public var subCaches: [DyldCache] {
        zip(subCacheSuffixes, fileHandle._files[1...])
            .map {
                .init(
                    unsafeFileHandle: $1._file,
                    url: .init(string: url.path + $0)!,
                    cpu: cpu,
                    mainCacheHeader: header
                )
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
                        $0.slideInfoFileSize + numericCast(file.offset)
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
            try mainCache.symbolCache
        }
    }

    /// Local symbol info
    public var localSymbolsInfo: DyldCacheLocalSymbolsInfo? {
        allCaches.lazy
            .compactMap {
                $0.localSymbolsInfo
            }
            .first
    }
}

extension FullDyldCache {
    /// Sequence of MachO information contained in this cache
    public func machOFiles() -> AnySequence<MachOFile> {
        guard let imageInfos else { return AnySequence([]) }
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
                guard let (url, segment) = self.urlAndFileSegment(forOffset: fileOffset) else {
                    return nil
                }
                return try? .init(
                    url: url,
                    imagePath: imagePath,
                    headerStartOffsetInCache: numericCast(fileOffset) - segment.offset
                )
            }

        return AnySequence(machOFiles)
    }

    public var dyld: MachOFile? {
        let fileOffset = header.dyldInCacheMH - header.sharedRegionStart
        guard let (url, segment) = self.urlAndFileSegment(forOffset: fileOffset) else {
            return nil
        }
        return try? MachOFile(
            url: url,
            imagePath: "/usr/lib/dyld",
            headerStartOffsetInCache: numericCast(fileOffset) - segment.offset
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
        guard let cache = cache(forOffset: offset) else {
            return nil
        }
        return cache.resolveRebase(at: offset)
    }

    /// File offset after optional rebasing performed on the specified file offset
    /// - Parameter offset: target file offset
    /// - Returns: optional rebased file offset
    ///
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/66c652a1f1f6b7b5266b8bbfd51cb0965d67cc44/common/MetadataVisitor.cpp#L435)
    /// `resolveOptionalRebase` differs from `resolveRebase` in that rebasing may or may not actually take place.
    public func resolveOptionalRebase(at offset: UInt64) -> UInt64? {
        guard let cache = cache(forOffset: offset) else {
            return nil
        }
        return cache.resolveOptionalRebase(at: offset)
    }
}

extension FullDyldCache {
    public func url(forOffset offset: UInt64) -> URL? {
        guard let index = fileHandle._files.firstIndex(
            where: {
                $0.offset <= offset && offset < $0.offset + $0.size
            }
        ) else { return nil }
        if index == 0 { return url }
        return .init(
            fileURLWithPath: url.path + subCacheSuffixes[index - 1]
        )
    }

    internal func fileSegment(forOffset offset: UInt64) -> File.FileSegment? {
        try? fileHandle._file(for: numericCast(offset))
    }

    internal func urlAndFileSegment(forOffset offset: UInt64) -> (URL, File.FileSegment)? {
        guard let index = fileHandle._files.firstIndex(
            where: {
                $0.offset <= offset && offset < $0.offset + $0.size
            }
        ) else { return nil }
        if index == 0 {
            return (url, fileHandle._files[0])
        }
        let url: URL = .init(
            fileURLWithPath: url.path + subCacheSuffixes[index - 1]
        )
        return (url, fileHandle._files[index])
    }

    public func cache(forOffset offset: UInt64) -> DyldCache? {
        guard let (url, segment) = urlAndFileSegment(forOffset: offset) else {
            return nil
        }
        return .init(
            unsafeFileHandle: segment._file,
            url: url,
            cpu: cpu,
            mainCacheHeader: header
        )
    }
}
