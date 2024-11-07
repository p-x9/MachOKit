//
//  DyldCache.swift
//
//
//  Created by p-x9 on 2024/01/13.
//  
//

import Foundation

public class DyldCache: DyldCacheRepresentable {
    /// URL of loaded dyld cache file
    public let url: URL
    let fileHandle: FileHandle

    public var headerSize: Int {
        header.actualSize
    }

    /// Header for dyld cache
    public let header: DyldCacheHeader

    /// Target CPU info.
    ///
    /// It is obtained based on magic.
    public let cpu: CPU

    private var _mainCacheHeader: DyldCacheHeader?

    /// Header for main dyld cache
    /// When this dyld cache is a subcache, represent the header of the main cache
    ///
    /// Some properties are only set for the main cache header
    /// https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/cache_builder/SubCache.cpp#L1353
    public var mainCacheHeader: DyldCacheHeader {
        _mainCacheHeader ?? header
    }

    /// Load dyld cache.
    /// - Parameter url: url for dyld cache
    /// - Important: Use ``init(subcacheUrl:mainCacheHeader:)`` to load sub cache
    public init(url: URL) throws {
        self.url = url
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle

        // read header
        self.header = fileHandle.read(
            offset: 0
        )

        // check magic of header
        guard header.magic.starts(with: "dyld_") else {
            throw MachOKitError.invalidMagic
        }

        guard let cpuType = header._cpuType,
              let cpuSubType = header._cpuSubType else {
            throw MachOKitError.invalidCpuType
        }
        self.cpu = .init(
            typeRawValue: cpuType.rawValue,
            subtypeRawValue: cpuSubType.rawValue
        )
    }

    /// Load sub dyld cache
    /// - Parameters:
    ///   - subcacheUrl: url for dyld cache
    ///   - mainCacheHeader: header of main dyld cache
    public convenience init(
        subcacheUrl: URL,
        mainCacheHeader: DyldCacheHeader
    ) throws {
        try self.init(url: subcacheUrl)
        self._mainCacheHeader = mainCacheHeader
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
        guard header.mappingWithSlideCount > 0,
              header.hasProperty(\.mappingWithSlideCount) else {
            return nil
        }
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
            numberOfElements: header.imagesCount
        )
    }

    /// Sequence of image text infos.
    public var imageTextInfos: DataSequence<DyldCacheImageTextInfo>? {
        guard header.imagesTextCount > 0,
              header.hasProperty(\.imagesTextCount) else {
            return nil
        }
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
        // https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/common/DyldSharedCache.cpp#L1763
        let hasCacheSuffix = header.hasProperty(\.cacheSubType)
        return hasCacheSuffix ? .general : .v1
    }

    /// Sequence of sub caches
    public var subCaches: SubCaches? {
        guard let subCacheEntryType,
              header.hasProperty(\.subCacheArrayCount) else {
            return nil
        }
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

    /// DyldCache containing unmapped local symbols
    public var symbolCache: DyldCache? {
        get throws {
            guard header.hasProperty(\.symbolFileUUID),
                  header.symbolFileUUID != .zero else {
                return nil
            }
            let suffix = ".symbols"
            let path = url.path + suffix
            return try .init(url: .init(fileURLWithPath: path))
        }
    }

    /// Local symbol info
    public var localSymbolsInfo: DyldCacheLocalSymbolsInfo? {
        guard header.localSymbolsSize > 0,
              header.hasProperty(\.localSymbolsSize) else {
            return nil
        }
        return fileHandle.read(
            offset: header.localSymbolsOffset
        )
    }
}

extension DyldCache {
    /// Sequence of MachO information contained in this cache
    public func machOFiles() -> AnySequence<MachOFile> {
        guard let imageInfos else {
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
    public var codeSign: MachOFile.CodeSign? {
        let data = fileHandle.readData(
            offset: header.codeSignatureOffset,
            size: numericCast(header.codeSignatureSize)
        )
        return .init(data: data)
    }
}

extension DyldCache {
    public typealias DylibsTrieEntries = DataTrieTree<DylibsTrieNodeContent>

    /// Dylibs trie is for searching by dylib name.
    ///
    /// The ``dylibIndices`` are retrieved from this trie tree．
    public var dylibsTrieEntries: DylibsTrieEntries? {
        guard mainCacheHeader.dylibsTrieAddr > 0,
              mainCacheHeader.hasProperty(\.dylibsTrieSize) else {
            return nil
        }
        guard let offset = fileOffset(of: mainCacheHeader.dylibsTrieAddr) else {
            return nil
        }
        let size = mainCacheHeader.dylibsTrieSize

        return DataTrieTree<DylibsTrieNodeContent>(
            data: fileHandle.readData(offset: offset, size: Int(size))
        )
    }

    /// Array of Dylib name-index pairs
    ///
    /// This index matches the index in the dylib image list that can be retrieved from imagesOffset.
    ///
    /// If an alias exists, there may be another element with an equal index.
    /// ```
    /// 0 /usr/lib/libobjc.A.dylib
    /// 0 /usr/lib/libobjc.dylib
    /// ```
    public var dylibIndices: [DylibIndex] {
        guard let dylibsTrieEntries else {
            return []
        }
        return dylibsTrieEntries.dylibIndices
    }
}

extension DyldCache {
    public typealias ProgramsTrieEntries = DataTrieTree<ProgramsTrieNodeContent>

    /// Pair of program name/cdhash and offset to prebuiltLoaderSet
    ///
    /// The ``programOffsets`` are retrieved from this trie tree．
    public var programsTrieEntries: ProgramsTrieEntries? {
        guard mainCacheHeader.programTrieAddr > 0,
              mainCacheHeader.hasProperty(\.programTrieSize) else {
            return nil
        }
        guard let offset = fileOffset(of: mainCacheHeader.programTrieAddr) else {
            return nil
        }
        let size = mainCacheHeader.programTrieSize

        return ProgramsTrieEntries(
            data: fileHandle.readData(offset: offset, size: Int(size))
        )
    }

    /// Pair of program name/cdhash and offset to prebuiltLoaderSet
    ///
    /// Example:
    /// ```
    /// 0 /System/Applications/App Store.app/Contents/MacOS/App Store
    /// 0 /cdhash/32caa391186c08b3b3cb7866995db1cb65b0376a
    /// 131776 /System/Applications/Automator.app/Contents/MacOS/Automator
    /// 131776 /cdhash/fed26a75645fed2a674b5c4d01001bfa69b9dbea
    /// ```
    public var programOffsets: [ProgramOffset] {
        guard let programsTrieEntries else {
            return []
        }
        return programsTrieEntries.programOffsets
    }

    /// Get the prebuiltLoaderSet indicated by programOffset.
    /// - Parameter programOffset: program name and offset pair
    /// - Returns: prebuiltLoaderSet
    public func prebuiltLoaderSet(for programOffset: ProgramOffset) -> PrebuiltLoaderSet? {
        guard mainCacheHeader.programsPBLSetPoolAddr > 0,
              mainCacheHeader.hasProperty(\.programsPBLSetPoolSize) else {
            return nil
        }
        let address: Int = numericCast(mainCacheHeader.programsPBLSetPoolAddr) + numericCast(programOffset.offset)
        guard let offset = fileOffset(of: numericCast(address)) else {
            return nil
        }
        let layout: prebuilt_loader_set = fileHandle.read(
            offset: offset
        )
        return .init(layout: layout, address: address)
    }
}

extension DyldCache {
    public var dylibsPrebuiltLoaderSet: PrebuiltLoaderSet? {
        guard mainCacheHeader.dylibsPBLSetAddr > 0,
              mainCacheHeader.hasProperty(\.dylibsPBLSetAddr) else {
            return nil
        }
        let address: Int = numericCast(mainCacheHeader.dylibsPBLSetAddr)
        guard let offset = fileOffset(of: numericCast(address)) else {
            return nil
        }
        let layout: prebuilt_loader_set = fileHandle.read(
            offset: offset
        )
        return .init(layout: layout, address: address)
    }
}

extension DyldCache {
    public var objcOptimization: ObjCOptimization? {
        guard mainCacheHeader.objcOptsOffset > 0,
              mainCacheHeader.hasProperty(\.objcOptsSize) else {
            return nil
        }
        let sharedRegionStart = mainCacheHeader.sharedRegionStart
        guard let offset = fileOffset(
            of: sharedRegionStart + numericCast(mainCacheHeader.objcOptsOffset)
        ) else {
            return nil
        }
        return fileHandle.read(offset: offset)
    }

    public var oldObjcOptimization: OldObjCOptimization? {
        guard let libobjc = machOFiles().first(where: {
            $0.imagePath == "/usr/lib/libobjc.A.dylib"
        }) else { return nil }

        let __objc_opt_ro: any SectionProtocol

        if libobjc.is64Bit {
            guard let _text = libobjc.loadCommands.text64,
                  let section = _text.sections(in: libobjc).first(where: {
                      $0.sectionName == "__objc_opt_ro"
                  }) else {
                return nil
            }
            __objc_opt_ro = section
        } else {
            guard let _text = libobjc.loadCommands.text,
                  let section = _text.sections(in: libobjc).first(where: {
                      $0.sectionName == "__objc_opt_ro"
                  }) else {
                return nil
            }
            __objc_opt_ro = section
        }

        let offset = __objc_opt_ro.offset + libobjc.headerStartOffset
        let layout: OldObjCOptimization.Layout = fileHandle.read(offset: numericCast(offset))
        guard let address = address(of: numericCast(offset)) else {
            return nil
        }

        return .init(
            layout: layout,
            offset: numericCast(address - mainCacheHeader.sharedRegionStart))
    }

    public var swiftOptimization: SwiftOptimization? {
        guard mainCacheHeader.swiftOptsOffset > 0,
              mainCacheHeader.hasProperty(\.swiftOptsSize) else {
            return nil
        }
        let sharedRegionStart = mainCacheHeader.sharedRegionStart
        guard let offset = fileOffset(
            of: sharedRegionStart + numericCast(mainCacheHeader.swiftOptsOffset)
        ) else {
            return nil
        }
        return fileHandle.read(offset: offset)
    }
}

extension DyldCache {
    /// File offset after rebasing performed on the specified file offset
    /// - Parameter offset: target file offset
    /// - Returns: rebased file offset
    ///
    /// [dyld Implementation](https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/common/MetadataVisitor.cpp#L262)
    public func resolveRebase(at offset: UInt64) -> UInt64? {
        guard let mappingInfos,
              let unslidLoadAddress = mappingInfos.first?.address else {
            return nil
        }
        guard let mapping = mappingAndSlideInfo(forFileOffset: offset) else {
            return nil
        }
        guard let slideInfo = mapping.slideInfo(in: self) else {
            let version = mapping.slideInfoVersion(in: self) ?? .none
            if version == .none {
                if cpu.is64Bit {
                    let value: UInt64 = fileHandle.read(offset: offset)
                    return value
                } else {
                    let value: UInt32 = fileHandle.read(offset: offset)
                    return numericCast(value)
                }
            } else {
                return nil
            }
        }

        let runtimeOffset: UInt64
        let onDiskDylibChainedPointerBaseAddress: UInt64
        switch slideInfo {
        case .v1:
            let value: UInt32 = fileHandle.read(offset: offset)
            runtimeOffset = numericCast(value) - unslidLoadAddress
            onDiskDylibChainedPointerBaseAddress = unslidLoadAddress

        case let .v2(slideInfo):
            let rawValue: UInt64 = fileHandle.read(offset: offset)
            let deltaMask: UInt64 = 0x00FFFF0000000000
            let valueMask: UInt64 = ~deltaMask
            runtimeOffset = rawValue & valueMask
            onDiskDylibChainedPointerBaseAddress = slideInfo.value_add

        case .v3:
            let rawValue: UInt64 = fileHandle.read(offset: offset)
            let _fixup = DyldChainedFixupPointerInfo.ARM64E(rawValue: rawValue)
            let fixup: DyldChainedFixupPointerInfo = .arm64e(_fixup)
            let pointer: DyldChainedFixupPointer = .init(
                offset: Int(offset),
                fixupInfo: fixup
            )
            guard let _runtimeOffset = pointer.rebaseTargetRuntimeOffset(
                preferedLoadAddress: unslidLoadAddress
            ) else { return nil }
            runtimeOffset = _runtimeOffset
            onDiskDylibChainedPointerBaseAddress = unslidLoadAddress

        case let .v4(slideInfo):
            let rawValue: UInt32 = fileHandle.read(offset: offset)
            let deltaMask: UInt64 = 0x00000000C0000000
            let valueMask: UInt64 = ~deltaMask
            runtimeOffset = numericCast(rawValue) & valueMask
            onDiskDylibChainedPointerBaseAddress = slideInfo.value_add

        case let .v5(slideInfo):
            let _fixup = DyldChainedFixupPointerInfo.ARM64ESharedCache(
                rawValue: fileHandle.read(offset: offset)
            )
            let fixup: DyldChainedFixupPointerInfo = .arm64e_shared_cache(_fixup)
            guard let rebase = fixup.rebase else {
                return nil
            }
            runtimeOffset = numericCast(rebase.unpackedTarget)
            onDiskDylibChainedPointerBaseAddress = slideInfo.value_add
        }

        return runtimeOffset + onDiskDylibChainedPointerBaseAddress
    }

    /// File offset after optional rebasing performed on the specified file offset
    /// - Parameter offset: target file offset
    /// - Returns: optional rebased file offset
    ///
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/a571176e8e00c47e95b95e3156820ebec0cbd5e6/common/MetadataVisitor.cpp#L424)
    /// `resolveOptionalRebase` differs from `resolveRebase` in that rebasing may or may not actually take place.
    public func resolveOptionalRebase(at offset: UInt64) -> UInt64? {
        // swiftlint:disable:previous cyclomatic_complexity
        guard let mappingInfos,
              let unslidLoadAddress = mappingInfos.first?.address else {
            return nil
        }
        guard let mapping = mappingAndSlideInfo(forFileOffset: offset) else {
            return nil
        }
        guard let slideInfo = mapping.slideInfo(in: self) else {
            let version = mapping.slideInfoVersion(in: self) ?? .none
            if version == .none {
                if cpu.is64Bit {
                    let value: UInt64 = fileHandle.read(offset: offset)
                    guard value != 0 else { return nil }
                    return value
                } else {
                    let value: UInt32 = fileHandle.read(offset: offset)
                    guard value != 0 else { return nil }
                    return numericCast(value)
                }
            } else {
                return nil
            }
        }

        let runtimeOffset: UInt64
        let onDiskDylibChainedPointerBaseAddress: UInt64
        switch slideInfo {
        case .v1:
            let value: UInt32 = fileHandle.read(offset: offset)
            guard value != 0 else { return nil }
            runtimeOffset = numericCast(value) - unslidLoadAddress
            onDiskDylibChainedPointerBaseAddress = unslidLoadAddress

        case let .v2(slideInfo):
            let rawValue: UInt64 = fileHandle.read(offset: offset)
            guard rawValue != 0 else { return nil }
            let deltaMask: UInt64 = 0x00FFFF0000000000
            let valueMask: UInt64 = ~deltaMask
            runtimeOffset = rawValue & valueMask
            onDiskDylibChainedPointerBaseAddress = slideInfo.value_add

        case .v3:
            let rawValue: UInt64 = fileHandle.read(offset: offset)
            guard rawValue != 0 else { return nil }
            let _fixup = DyldChainedFixupPointerInfo.ARM64E(rawValue: rawValue)
            let fixup: DyldChainedFixupPointerInfo = .arm64e(_fixup)
            let pointer: DyldChainedFixupPointer = .init(
                offset: Int(offset),
                fixupInfo: fixup
            )
            guard let _runtimeOffset = pointer.rebaseTargetRuntimeOffset(
                preferedLoadAddress: unslidLoadAddress
            ) else { return nil }
            runtimeOffset = _runtimeOffset
            onDiskDylibChainedPointerBaseAddress = unslidLoadAddress

        case let .v4(slideInfo):
            let rawValue: UInt32 = fileHandle.read(offset: offset)
            guard rawValue != 0 else { return nil }
            let deltaMask: UInt64 = 0x00000000C0000000
            let valueMask: UInt64 = ~deltaMask
            runtimeOffset = numericCast(rawValue) & valueMask
            onDiskDylibChainedPointerBaseAddress = slideInfo.value_add

        case let .v5(slideInfo):
            let rawValue: UInt64 = fileHandle.read(offset: offset)
            guard rawValue != 0 else { return nil }
            let _fixup = DyldChainedFixupPointerInfo.ARM64ESharedCache(
                rawValue: rawValue
            )
            let fixup: DyldChainedFixupPointerInfo = .arm64e_shared_cache(_fixup)
            guard let rebase = fixup.rebase else {
                return nil
            }
            runtimeOffset = numericCast(rebase.unpackedTarget)
            onDiskDylibChainedPointerBaseAddress = slideInfo.value_add
        }

        return runtimeOffset + onDiskDylibChainedPointerBaseAddress
    }
}
