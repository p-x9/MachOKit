//
//  DyldCache.swift
//
//
//  Created by p-x9 on 2024/01/13.
//  
//

import Foundation

public class DyldCache {
    /// URL of loaded dyld cache file
    public let url: URL
    let fileHandle: FileHandle

    public var headerSize: Int {
        DyldCacheHeader.layoutSize
    }

    /// Header for dyld cache
    public let header: DyldCacheHeader

    /// Target CPU info.
    ///
    /// It is obtained based on magic.
    public let cpu: CPU

    public init(url: URL) throws {
        self.url = url
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle

        // read header
        self.header = fileHandle.read(
            offset: 0
        )

        // check magic of header
        guard let cpuType = header._cpuType,
              let cpuSubType = header._cpuSubType else {
            throw NSError() // FIXME: error
        }
        self.cpu = .init(
            typeRawValue: cpuType.rawValue,
            subtypeRawValue: cpuSubType.rawValue
        )
    }

    deinit {
        fileHandle.closeFile()
    }
}

extension DyldCache {
    /// Sequence of mapping infos
    public var mappingInfos: DataSequence<DyldCacheMappingInfo>? {
        guard header.mappingCount > 0 else { return nil }
        return fileHandle.readDataSequence(
            offset: numericCast(header.mappingOffset),
            numberOfElements: numericCast(header.mappingCount)
        )
    }

    /// Sequence of mapping and slide infos
    public var mappingAndSlideInfos: DataSequence<DyldCacheMappingAndSlideInfo>? {
        guard header.mappingWithSlideCount > 0 else { return nil }
        return fileHandle.readDataSequence(
            offset: numericCast(header.mappingWithSlideOffset),
            numberOfElements: numericCast(header.mappingWithSlideCount)
        )
    }

    /// Sequence of image infos.
    public var imageInfos: DataSequence<DyldCacheImageInfo>? {
        guard header.imagesCount > 0 else { return nil }
        return fileHandle.readDataSequence(
            offset: numericCast(header.imagesOffset),
            numberOfElements: numericCast(header.imagesCount)
        )
    }

    /// Sequence of image text infos.
    public var imageTextInfos: DataSequence<DyldCacheImageTextInfo>? {
        guard header.imagesTextCount > 0 else { return nil }
        return fileHandle.readDataSequence(
            offset: numericCast(header.imagesTextOffset),
            numberOfElements: numericCast(header.imagesTextCount)
        )
    }

    /// Sub cache type
    ///
    /// Check if entry type is `dyld_subcache_entry_v1` or `dyld_subcache_entry`
    public var subCacheEntryType: DyldSubCacheEntryType? {
        guard header.subCacheArrayCount > 0 else {
            return nil
        }

        let subCache: DyldSubCacheEntryGeneral = fileHandle.read(
            offset: numericCast(header.subCacheArrayOffset)
        )

        if subCache.fileSuffix.starts(with: ".") {
            return .general
        } else {
            return .v1
        }
    }

    /// Local symbol info
    public var localSymbolsInfo: DyldCacheLocalSymbolsInfo? {
        guard header.localSymbolsSize > 0 else { return nil }
        return fileHandle.read(
            offset: header.localSymbolsOffset
        )
    }

    /// Sequence of sub caches
    public var subCaches: SubCaches? {
        guard let subCacheEntryType else { return nil }
        fileHandle.seek(toFileOffset: numericCast(header.subCacheArrayOffset))
        let data = fileHandle.readData(
            ofLength: DyldSubCacheEntryGeneral.layoutSize * numericCast(header.subCacheArrayCount)
        )
        return .init(
            data: data,
            numberOfSubCaches: numericCast(header.subCacheArrayCount),
            subCacheEntryType: subCacheEntryType
        )
    }
}

extension DyldCache {
    /// Sequence of MachO information contained in this cache
    public func machOFiles() -> AnySequence<MachOFile> {
        guard let imageInfos = imageInfos else {
            return AnySequence([])
        }
        let machOFiles = imageInfos
            .lazy
            .compactMap { info in
                guard let fileOffset = self.fileOffset(of: info.address),
                      let imagePath = info.path(in: self) else {
                    return nil
                }
                return (imagePath, fileOffset)
            }
            .compactMap { (imagePath: String, fileOffset: UInt64) -> MachOFile? in
                try? MachOFile(
                    url: self.url,
                    imagePath: imagePath,
                    headerStartOffsetInCache: numericCast(fileOffset)
                )
            }

        return AnySequence(machOFiles)
    }
}

extension DyldCache {
    public typealias DylibsTrieEntries = DataTrieTree<DylibsTrieNodeContent>

    public var dylibsTrieEntries: DylibsTrieEntries? {
        guard let offset = fileOffset(of: header.dylibsTrieAddr) else {
            return nil
        }
        let size = header.dylibsTrieSize

        return DataTrieTree<DylibsTrieNodeContent>(
            data: fileHandle.readData(offset: offset, size: Int(size))
        )
    }

    public var dylibIndices: [DylibIndex] {
        guard let dylibsTrieEntries else {
            return []
        }
        return dylibsTrieEntries.dylibIndices
    }
}

extension DyldCache {
    public var objcOptimization: ObjCOptimization? {
        let sharedRegionStart = header.sharedRegionStart
        guard let offset = fileOffset(
            of: sharedRegionStart + numericCast(header.objcOptsOffset)
        ) else {
            return nil
        }
        return fileHandle.read(offset: offset)
    }

    public var swiftOptimization: SwiftOptimization? {
        let sharedRegionStart = header.sharedRegionStart
        guard let offset = fileOffset(
            of: sharedRegionStart + numericCast(header.swiftOptsOffset)
        ) else {
            return nil
        }
        return fileHandle.read(offset: offset)
    }
}

extension DyldCache {
    public func fileOffset(of address: UInt64) -> UInt64? {
        guard let mappings = self.mappingInfos else { return nil }
        for mapping in mappings {
            if mapping.address <= address,
               address < mapping.address + mapping.size {
                return address - mapping.address + mapping.fileOffset
            }
        }
        return nil
    }
}
