//
//  DyldCache.swift
//
//
//  Created by p-x9 on 2024/01/13.
//  
//

import Foundation

public class DyldCache {
    public let url: URL
    let fileHandle: FileHandle

    public var headerSize: Int {
        DyldCacheHeader.layoutSize
    }

    public let header: DyldCacheHeader
    public let cpu: CPU

    public init(url: URL) throws {
        self.url = url
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle

        // read header
        let header = fileHandle.readData(
            ofLength: MemoryLayout<DyldCacheHeader>.size
        ).withUnsafeBytes {
            $0.load(as: DyldCacheHeader.self)
        }
        self.header = header

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
    public var mappingInfos: DataSequence<DyldCacheMappingInfo>? {
        readDataSequence(
            offset: numericCast(header.mappingOffset),
            count: numericCast(header.mappingCount)
        )
    }

    public var mappingAndSlideInfos: DataSequence<DyldCacheMappingAndSlideInfo>? {
        readDataSequence(
            offset: numericCast(header.mappingWithSlideOffset),
            count: numericCast(header.mappingWithSlideCount)
        )
    }

    public var imageInfos: DataSequence<DyldCacheImageInfo>? {
        readDataSequence(
            offset: numericCast(header.imagesOffset),
            count: numericCast(header.imagesCount)
        )
    }

    public var imageTextInfos: DataSequence<DyldCacheImageTextInfo>? {
        readDataSequence(
            offset: numericCast(header.imagesTextOffset),
            count: numericCast(header.imagesTextCount)
        )
    }

    /// check if entry type is `dyld_subcache_entry_v1` or `dyld_subcache_entry`
    public var subCacheEntryType: DyldSubCacheEntryType? {
        guard header.subCacheArrayCount > 0 else {
            return nil
        }

        fileHandle.seek(toFileOffset: numericCast(header.subCacheArrayOffset))
        let subCache: DyldSubCacheEntryGeneral? = fileHandle.readData(
            ofLength: DyldSubCacheEntryGeneral.layoutSize
        ).withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else { return nil }
            let ptr = baseAddress.assumingMemoryBound(to: DyldSubCacheEntryGeneral.Layout.self)
            return .init(layout: ptr.pointee)
        }

        guard let subCache else { return nil }

        if subCache.fileSuffix.starts(with: ".") {
            return .general
        } else {
            return .v1
        }
    }

    public var localSymbolsInfo: DyldCacheLocalSymbolsInfo? {
        guard header.localSymbolsSize > 0 else { return nil }
        fileHandle.seek(toFileOffset: header.localSymbolsOffset)
        let data = fileHandle.readData(
            ofLength: numericCast(header.localSymbolsSize)
        )
        return data.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else { return nil }
            let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                .assumingMemoryBound(to: DyldCacheLocalSymbolsInfo.self)
            return ptr.pointee
        }
    }

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
                return try? MachOFile(
                    url: self.url,
                    imagePath: imagePath,
                    headerStartOffsetInCache: numericCast(fileOffset)
                )
            }

        return AnySequence(machOFiles)
    }
}

extension DyldCache {
    private func readDataSequence<Element: LayoutWrapper>(
        offset: UInt64,
        count: Int
    ) -> DataSequence<Element>? {
        guard count > 0 else { return nil }

        fileHandle.seek(toFileOffset: offset)
        let data = fileHandle.readData(
            ofLength: count * Element.layoutSize
        )
        return .init(
            data: data,
            numberOfElements: count
        )
    }

    private func fileOffset(of address: UInt64) -> UInt64? {
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
