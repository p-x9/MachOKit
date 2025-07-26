//
//  DyldCacheLoaded.swift
//
//
//  Created by p-x9 on 2024/10/09
//
//

import Foundation

/// `DyldCacheLoaded` represents a dyld shared cache that is already loaded into memory.
///
/// It provides access to Mach-O images, mapping information, symbol data, and other
/// metadata directly from a memory-mapped dyld shared cache. This type is particularly
/// useful when analyzing the in-memory state of the dyld cache on Apple platforms.
///
/// - Note: ``DyldCacheLoaded`` works with a pointer to the start of the dyld shared cache
///   obtained by system APIs such as `_dyld_get_shared_cache_range`.
///
/// - SeeAlso: ``DyldCache``, ``FullDyldCache``
public struct DyldCacheLoaded: DyldCacheRepresentable {
    /// Address of dyld cache header start
    public let ptr: UnsafeRawPointer

    public var headerSize: Int {
        header.actualSize
    }

    /// Header for dyld cache
    public var header: DyldCacheHeader {
        .init(
            layout: ptr
                .assumingMemoryBound(to: dyld_cache_header.self)
                .pointee
        )
    }

    /// virtural memory address slide
    ///
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/common/DyldSharedCache.cpp#L817)
    public var slide: Int? {
        guard let mappingInfos,
              let info = mappingInfos.first else {
            return nil
        }
        return Int(bitPattern: ptr) - Int(info.address)
    }

    /// Target CPU info.
    ///
    /// It is obtained based on magic.
    public let cpu: CPU

    private var _mainCacheHeader: DyldCacheHeader?

    /// Header for main dyld cache
    /// When this dyld cache is a subcache, represent the header of the main cache
    ///
    /// Some properties are only set for the main cache header
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/cache_builder/SubCache.cpp#L1353)
    public var mainCacheHeader: DyldCacheHeader {
        _mainCacheHeader ?? header
    }

    /// Pointer of main cache
    public var mainCachePtr: UnsafeRawPointer {
        let diff = header.sharedRegionStart - mainCacheHeader.sharedRegionStart
        return ptr.advanced(by: -numericCast(diff))
    }

    /// Initialized with the start pointer of dyld cache loaded on memory.
    /// - Parameter ptr: start pointer of dyld cache header
    ///
    /// Using function named `_dyld_get_shared_cache_range`,  start pointer to the dyld cache can be obtained.
    public init(ptr: UnsafeRawPointer) throws {
        self.ptr = .init(ptr)

        let header: DyldCacheHeader = ptr.autoBoundPointee()

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
    ///   - subcachePtr: start pointer of sub dyld cache header
    ///   - mainCacheHeader: header of main dyld cache
    public init(
        subcachePtr: UnsafeRawPointer,
        mainCacheHeader: DyldCacheHeader
    ) throws {
        try self.init(ptr: subcachePtr)
        self._mainCacheHeader = mainCacheHeader
    }
}

extension DyldCacheLoaded {
    /// Sequence of mapping infos
    public var mappingInfos: MemorySequence<DyldCacheMappingInfo>? {
        guard header.mappingCount > 0 else { return nil }
        return .init(
            basePointer: ptr
                .advanced(by: numericCast(header.mappingOffset))
                .assumingMemoryBound(to: DyldCacheMappingInfo.self),
            numberOfElements: numericCast(header.mappingCount)
        )
    }

    /// Sequence of mapping and slide infos
    public var mappingAndSlideInfos: MemorySequence<DyldCacheMappingAndSlideInfo>? {
        guard header.mappingWithSlideCount > 0,
              header.hasProperty(\.mappingWithSlideCount) else {
            return nil
        }
        return .init(
            basePointer: ptr
                .advanced(by: numericCast(header.mappingWithSlideOffset))
                .assumingMemoryBound(to: DyldCacheMappingAndSlideInfo.self),
            numberOfElements: numericCast(header.mappingWithSlideCount)
        )
    }

    /// Sequence of image infos.
    public var imageInfos: MemorySequence<DyldCacheImageInfo>? {
        guard header.imagesCount > 0 else { return nil }
        return .init(
            basePointer: ptr
                .advanced(by: numericCast(header.imagesOffset))
                .assumingMemoryBound(to: DyldCacheImageInfo.self),
            numberOfElements: numericCast(header.imagesCount)
        )
    }

    /// Sequence of image text infos.
    public var imageTextInfos: MemorySequence<DyldCacheImageTextInfo>? {
        guard header.imagesTextCount > 0,
              header.hasProperty(\.imagesTextCount) else {
            return nil
        }
        return .init(
            basePointer: ptr
                .advanced(by: numericCast(header.imagesTextOffset))
                .assumingMemoryBound(to: DyldCacheImageTextInfo.self),
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
        return .init(
            basePointer: ptr
                .advanced(by: numericCast(header.subCacheArrayOffset)),
            numberOfSubCaches: numericCast(header.subCacheArrayCount),
            subCacheEntryType: subCacheEntryType
        )
    }

    /// Local symbol info
    public var localSymbolsInfo: DyldCacheLocalSymbolsInfo? {
        guard header.localSymbolsSize > 0,
              header.hasProperty(\.localSymbolsSize) else {
            return nil
        }
        return ptr
            .advanced(by: numericCast(header.localSymbolsOffset))
            .autoBoundPointee()
    }
}

extension DyldCacheLoaded {
    /// Sequence of MachO information contained in this cache
    public func machOImages() -> AnySequence<MachOImage> {
        guard let slide,
              let imageInfos else {
            return AnySequence([])
        }
        let machOFiles = imageInfos
            .lazy
            .compactMap { info in
                UnsafeRawPointer(bitPattern: Int(info.address) + slide)
            }
            .compactMap { ptr in
                MachOImage(
                    ptr: ptr.assumingMemoryBound(to: mach_header.self)
                )
            }

        return AnySequence(machOFiles)
    }

    public var dyld: MachOImage? {
        guard let slide,
              let ptr = UnsafeRawPointer(bitPattern: Int(header.dyldInCacheMH) + slide) else {
            return nil
        }
        
        return .init(ptr: ptr.assumingMemoryBound(to: mach_header.self))
    }
}

extension DyldCacheLoaded {
    public typealias DylibsTrie = MemoryTrieTree<DylibsTrieNodeContent>

    /// Dylibs trie is for searching by dylib name.
    ///
    /// The ``dylibIndices`` are retrieved from this trie tree．
    public var dylibsTrie: DylibsTrie? {
        guard header.dylibsTrieAddr > 0,
              header.hasProperty(\.dylibsTrieSize),
              let slide else {
            return nil
        }

        let address = UInt(header.dylibsTrieAddr) + UInt(slide)
        let size = header.dylibsTrieSize

        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }

        return .init(
            basePointer: basePointer,
            size: numericCast(size)
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
        guard let dylibsTrie else {
            return []
        }
        return dylibsTrie.dylibIndices
    }
}

extension DyldCacheLoaded {
    public typealias ProgramsTrie = MemoryTrieTree<ProgramsTrieNodeContent>

    /// Pair of program name/cdhash and offset to prebuiltLoaderSet
    ///
    /// The ``programOffsets`` are retrieved from this trie tree．
    public var programsTrie: ProgramsTrie? {
        guard header.programTrieAddr > 0,
              header.hasProperty(\.programTrieSize),
              let slide else {
            return nil
        }
        let address = UInt(header.programTrieAddr) + UInt(slide)
        let size = header.programTrieSize

        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }

        return ProgramsTrie(
            basePointer: basePointer,
            size: numericCast(size)
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
        guard let programsTrie else {
            return []
        }
        return programsTrie.programOffsets
    }

    /// Get the prebuiltLoaderSet indicated by programOffset.
    /// - Parameter programOffset: program name and offset pair
    /// - Returns: prebuiltLoaderSet
    public func prebuiltLoaderSet(for programOffset: ProgramOffset) -> PrebuiltLoaderSet? {
        guard header.programsPBLSetPoolAddr > 0,
              header.hasProperty(\.programsPBLSetPoolSize),
              let slide else {
            return nil
        }
        let address: Int = numericCast(header.programsPBLSetPoolAddr) + numericCast(programOffset.offset) + slide
        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        let layout: prebuilt_loader_set = basePointer
            .autoBoundPointee()
        return .init(layout: layout, address: .init(bitPattern: basePointer))
    }
}

extension DyldCacheLoaded {
    /// PrebuiltLoaderSet of all cached dylibs
    public var dylibsPrebuiltLoaderSet: PrebuiltLoaderSet? {
        guard header.dylibsPBLSetAddr > 0,
              header.hasProperty(\.dylibsPBLSetAddr),
              let slide else {
            return nil
        }
        let address: Int = numericCast(header.dylibsPBLSetAddr) + slide
        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        let layout: prebuilt_loader_set = basePointer
            .autoBoundPointee()
        return .init(layout: layout, address: address)
    }
}

extension DyldCacheLoaded {
    public var objcOptimization: ObjCOptimization? {
        guard header.objcOptsOffset > 0,
              header.hasProperty(\.objcOptsSize) else {
            return nil
        }
        return ptr
            .advanced(by: numericCast(header.objcOptsOffset))
            .autoBoundPointee()
    }

    public var oldObjcOptimization: OldObjCOptimization? {
        guard let libobjc = machOImages().first(where: {
            guard let idDylib = $0.loadCommands.info(of: LoadCommand.idDylib) else {
                return false
            }
            let dylib = idDylib.dylib(cmdsStart: $0.cmdsStartPtr)
            return dylib.name == "/usr/lib/libobjc.A.dylib"
        }) else { return nil }
        guard let vmaddrSlide = libobjc.vmaddrSlide else {
            return nil
        }

        let __objc_opt_ro: any SectionProtocol

        if libobjc.is64Bit {
            guard let _text = libobjc.loadCommands.text64,
                  let section = _text.sections(cmdsStart: libobjc.cmdsStartPtr).first(where: {
                      $0.sectionName == "__objc_opt_ro"
                  }) else {
                return nil
            }
            __objc_opt_ro = section
        } else {
            guard let _text = libobjc.loadCommands.text,
                  let section = _text.sections(cmdsStart: libobjc.cmdsStartPtr).first(where: {
                      $0.sectionName == "__objc_opt_ro"
                  }) else {
                return nil
            }
            __objc_opt_ro = section
        }

        guard let start = __objc_opt_ro.startPtr(
            vmaddrSlide: vmaddrSlide
        ) else { return nil }

        let layout: OldObjCOptimization.Layout = start
                .autoBoundPointee()

        return .init(
            layout: layout,
            offset: Int(bitPattern: start) - Int(bitPattern: ptr)
        )
    }

    public var swiftOptimization: SwiftOptimization? {
        guard header.swiftOptsOffset > 0,
              header.hasProperty(\.swiftOptsSize) else {
            return nil
        }
        return ptr
            .advanced(by: numericCast(header.swiftOptsOffset))
            .autoBoundPointee()
    }

    public var dynamicData: DyldCacheDynamicData? {
        guard mainCacheHeader.dynamicDataOffset > 0,
              mainCacheHeader.hasProperty(\.dynamicDataMaxSize) else {
            return nil
        }
        return ptr
            .advanced(by: numericCast(header.dynamicDataOffset))
            .autoBoundPointee()
    }

    public var tproMappings: MemorySequence<DyldCacheTproMappingInfo>? {
        guard mainCacheHeader.tproMappingsOffset > 0,
              mainCacheHeader.hasProperty(\.tproMappingsCount) else {
            return nil
        }
        return .init(
            basePointer: ptr
                .advanced(by: numericCast(mainCacheHeader.tproMappingsOffset))
                .assumingMemoryBound(to: DyldCacheTproMappingInfo.self),
            numberOfElements: numericCast(mainCacheHeader.tproMappingsCount)
        )
    }

    public var functionVariantInfo: DyldCacheFunctionVariantInfo? {
        guard header.functionVariantInfoAddr > 0,
              header.hasProperty(\.functionVariantInfoSize),
              let slide else {
            return nil
        }
        let address: Int = numericCast(header.functionVariantInfoAddr) + slide
        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        let layout: dyld_cache_function_variant_info = basePointer
            .autoBoundPointee()
        return .init(layout: layout, address: address)
    }

    public var prewarmingData: DyldCachePrewarming? {
        guard mainCacheHeader.prewarmingDataOffset > 0,
              mainCacheHeader.hasProperty(\.prewarmingDataSize) else {
            return nil
        }
        return .init(
            layout: ptr
                .advanced(by: numericCast(mainCacheHeader.prewarmingDataOffset))
                .assumingMemoryBound(to: dyld_prewarming_header.self)
                .pointee,
            offset: numericCast(mainCacheHeader.prewarmingDataOffset)
        )
    }
}
