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
#else
@_implementationOnly import FileIO
#endif

internal protocol _DyldCacheFileRepresentable: DyldCacheRepresentable
where DylibsTrie == DataTrieTree<DylibsTrieNodeContent>,
      ProgramsTrie == DataTrieTree<ProgramsTrieNodeContent>
{
    associatedtype File: FileIOProtocol
    var fileHandle: File { get }

    func machOFiles() -> AnySequence<MachOFile>
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

        guard let offset = fileOffset(of: numericCast(__objc_opt_ro.address)) else {
            return nil
        }
        let layout: OldObjCOptimization.Layout = try! fileHandle.read(
            offset: numericCast(offset)
        )
        // `libobjc` exists only in main cache.
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
