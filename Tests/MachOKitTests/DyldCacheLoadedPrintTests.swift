//
//  DyldCacheLoadedPrintTests.swift
//
//
//  Created by p-x9 on 2024/10/10
//
//

import XCTest
@testable import MachOKit

#if canImport(Darwin)

final class DyldCacheLoadedPrintTests: XCTestCase {
    var cache: DyldCacheLoaded!
    var cache1: DyldCacheLoaded!

    override func setUp() {
        print("----------------------------------------------------")
        var size = 0
        guard let ptr = _dyld_get_shared_cache_range(&size) else {
           return
        }
        cache = try? .init(ptr: ptr)
        cache1 = try? Array(cache.subCaches!)[0]
            .subcache(for: cache)
    }

    func testHeader() throws {
        let header = cache.header
        print("Magic:", header.magic)
        print("UUID:", header.uuid)
        print("CacheType:", header.cacheType!)
        print("Mappings:", header.mappingCount)
        print("Images:", header.imagesCount)
        print("Platform:", header.platform)
        print("OS Version:", header.osVersion)
        print("isSimulator:", header.isSimulator)
        print("Alt Platform:", header.altPlatform)
        print("Alt OS Version:", header.altOsVersion)
        print("CPU:", cache.cpu)
//        dump(header.layout)
    }

    func testMappingInfos() throws {
        guard let infos = cache.mappingInfos else {
            return
        }
        for info in infos {
            print("----")
            print("Address:", String(info.address, radix: 16))
            print("File Offset::", String(info.fileOffset, radix: 16))
            print("Size:", String(info.size, radix: 16))
            print("MaxProtection:", info.maxProtection.bits)
            print("InitProtection:", info.initialProtection.bits)
        }
    }

    func testMappingAndSlideInfos() throws {
        guard let infos = cache.mappingAndSlideInfos else {
            return
        }
        for info in infos {
            print("----")
            print("Address:", String(info.address, radix: 16))
            print("Name:", info.mappingName ?? "unknown")
            print("File Offset::", String(info.fileOffset, radix: 16))
            print("Size:", String(info.size, radix: 16))
            print("Flags:", info.flags.bits)
            print("MaxProtection:", info.maxProtection.bits)
            print("InitProtection:", info.initialProtection.bits)
        }
    }

    func testImageInfos() throws {
        guard let infos = cache.imageInfos else {
            return
        }

        print("Images:", cache.header.imagesCount)
        for info in infos {
            print("----")
            print("Address:", String(info.address, radix: 16))
            print("Path:", info.path(in: cache) ?? "unknown")
        }
    }

    func testImageTextInfos() throws {
        guard let infos = cache.imageTextInfos else {
            return
        }
        print("ImageTexts:", cache.header.imagesTextCount)
        for info in infos {
            print("----")
            print("Address:", String(info.loadAddress, radix: 16))
            print("Path:", info.path(in: cache) ?? "unknown")
            print("UUID:", info.uuid)
        }
    }

    func testSubCaches() throws {
        guard let subCaches = cache.subCaches else { return }
        for subCache in subCaches {
            print("----")
            print("UUID:", subCache.uuid)
            print("VM Offset:", String(subCache.cacheVMOffset, radix: 16))
            print("File Suffix:", subCache.fileSuffix)
            print(
                "Path:",
                subCache.fileSuffix
            )
        }
    }

    func testLocalSymbolsInfo() throws {
        guard let symbolsInfo = cache.localSymbolsInfo else {
            return
        }

        let symbols = symbolsInfo.symbols(in: cache)
        for symbol in symbols {
            print(
                String(symbol.offset, radix: 16),
                symbol.demangledName
            )
        }
    }

    func testLocalSymbolsInfoEntries() throws {
        guard let symbolsInfo = cache.localSymbolsInfo else {
            return
        }

        let entries = symbolsInfo.entries(in: cache)
        let symbols = Array(symbolsInfo.symbols(in: cache))

        for entry in entries {
            let start = entry.nlistStartIndex
            let end = entry.nlistStartIndex + entry.nlistCount
            print(
                "Offset:", String(entry.dylibOffset, radix: 16),
                "Symbols:", symbols[start ..< end].count
            )
        }
    }

    func testMachOImages() throws {
        let machOs = cache.machOImages()
        for machO in machOs {
            print(
                machO.loadCommands.info(of: LoadCommand.idDylib)?
                    .dylib(cmdsStart: machO.cmdsStartPtr)
                    .name ?? "Unknown",
                machO.header.ncmds
            )
        }
    }

    func testDylibIndices() {
        let cache = cache!
        let indices = cache.dylibIndices
            .sorted(by: { lhs, rhs in
                lhs.index < rhs.index
            })
        let trie = cache.dylibsTrie
        for index in indices {
            let found = trie?.search(for: index.name)
            XCTAssertNotNil(found)
            XCTAssertEqual(found?.index, index.index)

            print(index.index, index.name)
        }
    }

    func testProgramOffsets() {
        let cache = cache!
        let programOffsets = cache.programOffsets
        let trie = cache.programsTrie
        for programOffset in programOffsets {
            let found = trie?.search(for: programOffset.name)
            XCTAssertNotNil(found)
            XCTAssertEqual(found?.offset, programOffset.offset)

            print(programOffset.offset, programOffset.name)
        }
    }

    func testProgramPreBuildLoaderSet() {
        let cache = self.cache!
        let programOffsets = cache.programOffsets
        for programOffset in programOffsets {
            guard !programOffset.name.starts(with: "/cdhash") else {
                continue
            }
            guard let loaderSet = cache.prebuiltLoaderSet(for: programOffset) else {
                continue
            }
            print("Name:", programOffset.name)
            print("Loaders:")
            for loader in loaderSet.loaders(in: cache)! {
                print("  \(loader.path(in: cache) ?? "unknown")")
            }
            for loader in loaderSet.loaders_pre1165_3(in: cache) ?? [] {
                print("  \(loader.path(in: cache) ?? "unknown")")
            }
            let dyldCacheUUID = loaderSet.dyldCacheUUID(in: cache)
            print("dyldCacheUUID:", dyldCacheUUID?.uuidString ?? "None")
            let mustBeMissingPaths = loaderSet.mustBeMissingPaths(in: cache) ?? []
            print("mustBeMissingPaths:")
            for path in mustBeMissingPaths {
                print("", path)
            }
        }
    }

    func testDylibsPreBuildLoaderSet() {
        let cache = self.cache!
        guard let loaderSet = cache.dylibsPrebuiltLoaderSet else {
            return
        }
        XCTAssertNotNil(loaderSet.version)
        print("Loaders:")
        for loader in loaderSet.loaders(in: cache) ?? [] {
            print("  \(loader.path(in: cache) ?? "unknown")")
        }
        for loader in loaderSet.loaders_pre1165_3(in: cache) ?? [] {
            print("  \(loader.path(in: cache) ?? "unknown")")
        }
    }

    func testObjCOptimization() throws {
        guard let objcOptimization = cache.objcOptimization else { return }
        print("Version:", objcOptimization.version)
        print("Flags:", objcOptimization.flags)
        print("Header Info RO Cache Offset:", objcOptimization.headerInfoROCacheOffset)
        print("Header Info RW Cache Offset:", objcOptimization.headerInfoRWCacheOffset)
        print("Selector Hash Table Cache Offset:", objcOptimization.selectorHashTableCacheOffset)
        print("Class Hash Table Cache Offset:", objcOptimization.classHashTableCacheOffset)
        print("Protocol Hash Table Cache Offset:", objcOptimization.protocolHashTableCacheOffset)
        print("Relative Method Selector Base Address Offset:", objcOptimization.relativeMethodSelectorBaseAddressOffset)
    }

    func testObjCMethodSelectorBaseAddress() {
        print("Relative method selector base")
        print(
            " Expected            :",
            unsafeBitCast(NSSelectorFromString("🤯"), to: UnsafeRawPointer.self)
        )

        if let oldObjcOptimization = cache.oldObjcOptimization {
            print(
                " old objcOptimization:",
                oldObjcOptimization.relativeMethodSelectorBaseAddress(in: cache)
            )
        }

        if let objcOptimization = cache.objcOptimization {
            print(
                " objcOptimization    :",
                objcOptimization.relativeMethodSelectorBaseAddress(in: cache)
            )
        }
    }

    func testObjCHeaderOptimizationRW() throws {
        guard let objcOptimization = cache.objcOptimization else { return }
        let rw = objcOptimization.headerOptimizationRW64(in: cache)!
        let rwHeaders = rw.headerInfos(in: cache)
        print("Count:", rw.count)
        print("EntrySize:", rw.entrySize)
        for info in rwHeaders {
            print(" isLoaded: \(info.isLoaded), isAllClassesRelized: \(info.isAllClassesRelized)")
        }
    }

    func testObjCHeaderOptimizationRO() throws {
        guard let objcOptimization = cache.oldObjcOptimization else { return }
        let ro = objcOptimization.headerOptimizationRO64(in: cache)!
        let roHeaders = ro.headerInfos(in: cache)
        print("Count:", ro.count)
        print("EntrySize:", ro.entrySize)

        print("Image Info:")
        for info in roHeaders {
            guard let imageInfo = info.imageInfo(in: cache) else {
                print(" nil")
                continue
            }
            print(" Flags: \(imageInfo.flags.bits), Version: \(imageInfo.version)")
        }

        print("Image:")
        for info in roHeaders {
            guard let machO = info.machO(
                in: cache
            ) else {
                print(" nil")
                continue
            }

            let _info = ro.headerInfo(in: cache, for: machO)!
            XCTAssertEqual(info.mhdr_offset, _info.mhdr_offset)
            XCTAssertEqual(info.info_offset, _info.info_offset)

            let path = machO.loadCommands
                .info(of: LoadCommand.idDylib)?
                .dylib(cmdsStart: machO.cmdsStartPtr)
                .name ?? "unknown"
            print(" \(path)")
        }
    }

    func testSwiftOptimization() throws {
        guard let swiftOptimization = cache.swiftOptimization else { return }
        print("Version:", swiftOptimization.version)
        print("Padding:", swiftOptimization.padding)
        print("Type Conformance Hash Table Cache Offset:", swiftOptimization.typeConformanceHashTableCacheOffset)
        print("Metadata Conformance Hash Table Cache Offset:", swiftOptimization.metadataConformanceHashTableCacheOffset)
        print("Foreign Type Conformance Hash Table Cache Offset:", swiftOptimization.foreignTypeConformanceHashTableCacheOffset)
    }

    func testTproMappings() throws {
        guard let mappings = cache.tproMappings else { return }
        for mapping in mappings {
            print("- 0x\(String(mapping.unslidAddress, radix: 16)), \(mapping.size)")
        }
    }
}

#endif
