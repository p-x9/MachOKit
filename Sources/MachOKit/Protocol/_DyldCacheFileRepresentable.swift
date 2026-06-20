//
//  _DyldCacheFileRepresentable.swift
//  MachOKit
//
//  Created by p-x9 on 2025/07/19
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

internal protocol _DyldCacheFileRepresentable: DyldCacheRepresentable
where MappingInfos == [DyldCacheMappingInfo],
      MappingAndSlideInfos == [DyldCacheMappingAndSlideInfo],
      DylibsTrie == DataTrieTree<DylibsTrieNodeContent>,
      ProgramsTrie == DataTrieTree<ProgramsTrieNodeContent>
{
    associatedtype File: MemoryMappedFileIOProtocol
    var fileHandle: File { get }

    func machOFiles() -> AnySequence<MachOFile>
}

extension _DyldCacheFileRepresentable {
    @inline(__always)
    public func mappingInfo(for address: UInt64) -> DyldCacheMappingInfo? {
        guard let mappings = mappingInfos else { return nil }
        for mapping in mappings {
            if mapping.address <= address,
               address < mapping.address + mapping.size {
                return mapping
            }
        }
        return nil
    }

    @inline(__always)
    public func mappingInfo(
        forFileOffset offset: UInt64
    ) -> DyldCacheMappingInfo? {
        guard let mappings = mappingInfos else { return nil }
        for mapping in mappings {
            if mapping.fileOffset <= offset,
               offset < mapping.fileOffset + mapping.size {
                return mapping
            }
        }
        return nil
    }

    @inline(__always)
    public func mappingAndSlideInfo(
        for address: UInt64
    ) -> DyldCacheMappingAndSlideInfo? {
        guard let mappings = mappingAndSlideInfos else { return nil }
        for mapping in mappings {
            if mapping.address <= address,
               address < mapping.address + mapping.size {
                return mapping
            }
        }
        return nil
    }

    @inline(__always)
    public func mappingAndSlideInfo(
        forFileOffset offset: UInt64
    ) -> DyldCacheMappingAndSlideInfo? {
        guard let mappings = mappingAndSlideInfos else { return nil }
        for mapping in mappings {
            if mapping.fileOffset <= offset,
               offset < mapping.fileOffset + mapping.size {
                return mapping
            }
        }
        return nil
    }
}

extension _DyldCacheFileRepresentable {
    func _resolveRebase(
        at offset: UInt64,
        skipsZeroValue: Bool
    ) -> UInt64? {
        guard let mapping = mappingAndSlideInfo(forFileOffset: offset) else {
            return nil
        }
        guard let slideInfo = mapping.slideInfo(in: self) else {
            let version = mapping.slideInfoVersion(in: self) ?? .none
            if version == .none {
                if cpu.is64Bit {
                    let value: UInt64 = fileHandle.read(offset: offset)
                    guard !skipsZeroValue || value != 0 else { return nil }
                    return value
                } else {
                    let value: UInt32 = fileHandle.read(offset: offset)
                    guard !skipsZeroValue || value != 0 else { return nil }
                    return numericCast(value)
                }
            } else {
                return nil
            }
        }

        let unslidLoadAddress = mainCacheHeader.sharedRegionStart

        let runtimeOffset: UInt64
        let onDiskDylibChainedPointerBaseAddress: UInt64
        switch slideInfo {
        case .v1:
            let value: UInt32 = fileHandle.read(offset: offset)
            guard !skipsZeroValue || value != 0 else { return nil }
            runtimeOffset = numericCast(value) - unslidLoadAddress
            onDiskDylibChainedPointerBaseAddress = unslidLoadAddress

        case let .v2(slideInfo):
            let rawValue: UInt64 = fileHandle.read(offset: offset)
            guard !skipsZeroValue || rawValue != 0 else { return nil }
            let deltaMask: UInt64 = 0x00FFFF0000000000
            let valueMask: UInt64 = ~deltaMask
            runtimeOffset = rawValue & valueMask
            onDiskDylibChainedPointerBaseAddress = slideInfo.value_add

        case .v3:
            let rawValue: UInt64 = fileHandle.read(offset: offset)
            guard !skipsZeroValue || rawValue != 0 else { return nil }
            let _fixup = DyldChainedFixupPointerInfo.ARM64E(rawValue: rawValue)
            let fixup: DyldChainedFixupPointerInfo = .arm64e(_fixup)
            let pointer: DyldChainedFixupPointer = .init(
                offset: Int(offset),
                fixupInfo: fixup
            )
            guard let _runtimeOffset = pointer.rebaseTargetRuntimeOffset(
                for: self,
                preferedLoadAddress: unslidLoadAddress
            ) else { return nil }
            runtimeOffset = _runtimeOffset
            onDiskDylibChainedPointerBaseAddress = unslidLoadAddress

        case let .v4(slideInfo):
            let rawValue: UInt32 = fileHandle.read(offset: offset)
            guard !skipsZeroValue || rawValue != 0 else { return nil }
            let deltaMask: UInt64 = 0x00000000C0000000
            let valueMask: UInt64 = ~deltaMask
            runtimeOffset = numericCast(rawValue) & valueMask
            onDiskDylibChainedPointerBaseAddress = slideInfo.value_add

        case .v5:
            let rawValue: UInt64 = fileHandle.read(offset: offset)
            guard !skipsZeroValue || rawValue != 0 else { return nil }
            let _fixup = DyldChainedFixupPointerInfo.ARM64ESharedCache(
                rawValue: rawValue
            )
            let fixup: DyldChainedFixupPointerInfo = .arm64e_shared_cache(_fixup)
            let pointer: DyldChainedFixupPointer = .init(
                offset: Int(offset),
                fixupInfo: fixup
            )
            guard let _runtimeOffset = pointer.rebaseTargetRuntimeOffset(
                for: self,
                preferedLoadAddress: unslidLoadAddress
            ) else { return nil }
            runtimeOffset = _runtimeOffset
            onDiskDylibChainedPointerBaseAddress = unslidLoadAddress
        }

        return runtimeOffset + onDiskDylibChainedPointerBaseAddress
    }
}

extension _DyldCacheFileRepresentable {
    public var dylibsTrie: DylibsTrie? {
        guard mainCacheHeader.dylibsTrieAddr > 0,
              mainCacheHeader.hasProperty(\.dylibsTrieSize) else {
            return nil
        }
        guard let offset = fileOffset(of: mainCacheHeader.dylibsTrieAddr) else {
            return nil
        }
        let size = mainCacheHeader.dylibsTrieSize

        return DataTrieTree<DylibsTrieNodeContent>(
            data: try! fileHandle.readData(
                offset: numericCast(offset),
                length: numericCast(size)
            )
        )
    }
}

extension _DyldCacheFileRepresentable {
    public var programsTrie: ProgramsTrie? {
        guard mainCacheHeader.programTrieAddr > 0,
              mainCacheHeader.hasProperty(\.programTrieSize) else {
            return nil
        }
        guard let offset = fileOffset(of: mainCacheHeader.programTrieAddr) else {
            return nil
        }
        let size = mainCacheHeader.programTrieSize

        return ProgramsTrie(
            data: try! fileHandle.readData(
                offset: numericCast(offset),
                length: numericCast(size)
            )
        )
    }

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

extension _DyldCacheFileRepresentable {
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

extension _DyldCacheFileRepresentable {
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

        return .load(
            from: numericCast(__objc_opt_ro.address),
            in: libobjc
        )
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

    public var tproMappings: DataSequence<DyldCacheTproMappingInfo>? {
        guard mainCacheHeader.tproMappingsOffset > 0,
              mainCacheHeader.hasProperty(\.tproMappingsCount) else {
            return nil
        }
        let sharedRegionStart = mainCacheHeader.sharedRegionStart
        guard let offset = fileOffset(
            of: sharedRegionStart + numericCast(mainCacheHeader.tproMappingsOffset)
        ) else {
            return nil
        }
        return fileHandle.readDataSequence(
            offset: offset,
            numberOfElements: numericCast(mainCacheHeader.tproMappingsCount)
        )
    }

    public var functionVariantInfo: DyldCacheFunctionVariantInfo? {
        guard mainCacheHeader.functionVariantInfoAddr > 0,
              mainCacheHeader.hasProperty(\.functionVariantInfoSize) else {
            return nil
        }
        let address: Int = numericCast(mainCacheHeader.functionVariantInfoAddr)
        guard let offset = fileOffset(of: numericCast(address)) else {
            return nil
        }
        let layout: dyld_cache_function_variant_info = fileHandle.read(
            offset: offset
        )
        return .init(layout: layout, address: address)
    }

    public var prewarmingData: DyldCachePrewarming? {
        guard mainCacheHeader.prewarmingDataOffset > 0,
              mainCacheHeader.hasProperty(\.prewarmingDataSize) else {
            return nil
        }
        let sharedRegionStart = mainCacheHeader.sharedRegionStart
        guard let fileOffset = fileOffset(
            of: sharedRegionStart + numericCast(mainCacheHeader.prewarmingDataOffset)
        ) else {
            return nil
        }
        let layout: dyld_prewarming_header = fileHandle.read(
            offset: fileOffset
        )
        return .init(
            layout: layout,
            offset: numericCast(mainCacheHeader.prewarmingDataOffset)
        )
    }
}
