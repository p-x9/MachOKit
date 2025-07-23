//
//  DyldCachePrintTests.swift
//
//
//  Created by p-x9 on 2024/01/13.
//
//

import XCTest
@testable import MachOKit
import FileIO

final class DyldCachePrintTests: XCTestCase {
    private var cache: DyldCache!
    private var cache1: DyldCache!

    override func setUp() {
        print("----------------------------------------------------")
        let arch = "arm64e"
        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_\(arch)"
//        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_\(arch).01"
//        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/DriverKit/System/Library/dyld/dyld_shared_cache_\(arch)"
//        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/DriverKit/System/Library/dyld/dyld_shared_cache_\(arch).symbols"
        let url = URL(fileURLWithPath: path)

        self.cache = try! DyldCache(url: url)
        self.cache1 = try! DyldCache(
            subcacheUrl: URL(fileURLWithPath: path + ".01"),
            mainCacheHeader: cache.header
        )
    }

    func test() throws {
        let urls = [cache.url] + cache.subCaches!.map {
            URL(fileURLWithPath: cache.url.path + $0.fileSuffix)
        }
        let fileHandle = try ConcatenatedMemoryMappedFile.open(
            urls: urls,
            isWritable: false
        )
        let lcache = try DyldCacheLoaded(ptr: fileHandle.ptr)
        print(lcache)
    }

    func test2() throws {
        let cache = try FullDyldCache(url: cache.url)
        print(cache.machOFiles().map(\.imagePath))
        print(cache)
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
            if let slideInfo = info.slideInfo(in: cache) {
                print("SlideInfo")
                print(" Version:", slideInfo.version.rawValue)
                print(" Info:", slideInfo)
            }
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
                cache.url.path + subCache.fileSuffix
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

    func testMachOFiles() throws {
        let machOs = cache.machOFiles()
        for machO in machOs {
            print(
                String(machO.headerStartOffsetInCache, radix: 16),
                machO.imagePath,
                machO.header.ncmds
            )
        }
    }

    func testDyld() throws {
        guard let dyld = cache.dyld else { return }
        let sourceVersion = dyld.loadCommands.info(of: LoadCommand.sourceVersion)!
        print("Dyld:", dyld.imagePath, "dyld-\(sourceVersion.version)")
        for cmd in dyld.loadCommands {
            print(" -", cmd.type)
        }
    }

    func testDylibIndices() {
        let cache = self.cache1!
        let indices = cache.dylibIndices
            .sorted(by: { lhs, rhs in
                lhs.index < rhs.index
            })
        let trie = cache.dylibsTrie
        for index in indices {
            let found = trie?.search(by: index.name)
            XCTAssertNotNil(found)
            XCTAssertEqual(found?.index, index.index)

            print(index.index, index.name)
        }
    }

    func testProgramOffsets() {
        let cache = self.cache1!
        let programOffsets = cache.programOffsets
        let trie = cache.programsTrie
        for programOffset in programOffsets {
            let found = trie?.search(by: programOffset.name)
            XCTAssertNotNil(found)
            XCTAssertEqual(found?.offset, programOffset.offset)
            print(programOffset.offset, programOffset.name)
        }
    }

    func testProgramPreBuildLoaderSet() {
        let cache = self.cache1!
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
        let cache = self.cache1!
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

    func testObjCHeaderOptimizationRW() throws {
        guard let objcOptimization = cache.objcOptimization else { return }
        let rw = objcOptimization.headerOptimizationRW64(in: cache)!
        let rwHeaders = rw.headerInfos(in: cache)!
        print("Count:", rw.count)
        print("EntrySize:", rw.entrySize)
        for info in rwHeaders {
            print(" isLoaded: \(info.isLoaded), isAllClassesRelized: \(info.isAllClassesRelized)")
        }
    }

    func testObjCHeaderOptimizationRO() throws {
        guard let objcOptimization = cache.objcOptimization else { return }
        let ro = objcOptimization.headerOptimizationRO64(in: cache)!
        let roHeaders = ro.headerInfos(in: cache)!
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

            print(" \(machO.imagePath), offset: \(machO.headerStartOffsetInCache)")
        }
    }

    func testSwiftOptimization() throws {
        guard let swiftOptimization = cache.swiftOptimization else { return }
        print("Version:", swiftOptimization.version)
        print("Padding:", swiftOptimization.padding)
        print("Type Conformance Hash Table Cache Offset:", swiftOptimization.typeConformanceHashTableCacheOffset)
        print("Metadata Conformance Hash Table Cache Offset:", swiftOptimization.metadataConformanceHashTableCacheOffset)
        print("Foreign Type Conformance Hash Table Cache Offset:", swiftOptimization.foreignTypeConformanceHashTableCacheOffset)
        print("Prespecialized Data Cache Offset:", swiftOptimization.prespecializationDataCacheOffset)
        print("Prespecialized Metadata Hash Table Cache Offset:", swiftOptimization.prespecializedMetadataHashTableCacheOffsets)
    }

    func testTproMappings() throws {
        guard let mappings = cache.tproMappings else { return }
        for mapping in mappings {
            print("- 0x\(String(mapping.unslidAddress, radix: 16)), \(mapping.size)")
        }
    }

    func testFunctionVariantInfo() throws {
        guard let variantInfo = cache1.functionVariantInfo else { return }
        print("Version:", variantInfo.layout.version)
        print("Count:", variantInfo.layout.count)
        guard let entries = variantInfo.entries(in: cache) else {
            if variantInfo.layout.count > 0 {
                XCTFail()
            }
            return
        }
        for entry in entries {
            print(" ", entry.layout)
        }
    }

    func testPrewarmingData() throws {
        let caches = [cache!] + cache.subCaches!
            .compactMap {
                try! $0.subcache(for: cache)
            }
        for cache in caches {
            guard let prewarmingData = cache.prewarmingData else { continue }
            print("Version:", prewarmingData.layout.version)
            print("Count:", prewarmingData.layout.count)
            guard let entries = prewarmingData.entries(in: cache) else {
                if prewarmingData.layout.count > 0 {
                    XCTFail()
                }
                return
            }
            for entry in entries {
                print(
                    " ",
                    "cacheVMOffset:", entry.layout.cacheVMOffset,
                    "pages:", entry.layout.numPages
                )
            }
        }
    }
}

extension DyldCachePrintTests {
    func testCodeSign() {
        guard let codeSign = cache.codeSign else {
            return
        }
        guard let superBlob = codeSign.superBlob else {
            return
        }
        let indices = superBlob.blobIndices(in: codeSign)
        print(
            indices.compactMap(\.type)
        )
    }

    func testCodeSignCodeDirectories() {
        guard let codeSign = cache.codeSign else {
            return
        }
        let directories = codeSign.codeDirectories

        /* Identifier */
        let identifiers = directories
            .compactMap {
                $0.identifier(in: codeSign)
            }
        print(
            "identifier:",
            identifiers
        )

        /* CD Hash */
        let cdHashes = directories
            .compactMap {
                $0.hash(in: codeSign)
            }.map {
                $0.map { String(format: "%02x", $0) }.joined()
            }
        print(
            "CDHash:",
            cdHashes
        )

        /* Page Hashes*/
        //        let pageHashes = directories
        //            .map { directory in
        //                (-Int(directory.nSpecialSlots)..<Int(directory.nCodeSlots))
        //                    .map {
        //                        if let hash = directory.hash(forSlot: $0, in: codeSign) {
        //                            return "\($0) " + hash.map { String(format: "%02x", $0) }.joined()
        //                        } else {
        //                            return "\($0) unknown"
        //                        }
        //                    }
        //            }
        //        print(
        //            "PageHashes:",
        //            pageHashes
        //        )

        /* Team IDs */
        let teamIDs = directories
            .compactMap {
                $0.teamId(in: codeSign)
            }
        print(
            "TeamID:",
            teamIDs
        )

        /* Exec Segment */
        let execSeg = directories
            .compactMap {
                $0.executableSegment(in: codeSign)
            }
        print(
            "ExecSeg:",
            execSeg
        )

        /* Runtime */
        let runtime = directories
            .compactMap {
                $0.runtime(in: codeSign)
            }
        print(
            "Runtime:",
            runtime
        )
    }
}
