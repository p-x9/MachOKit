//
//  DyldCachePrintTests.swift
//
//
//  Created by p-x9 on 2024/01/13.
//
//

import XCTest
@testable import MachOKit

final class DyldCachePrintTests: XCTestCase {
    private var cache: DyldCache!

    override func setUp() {
        print("----------------------------------------------------")
        let arch = "x86_64h"
        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_\(arch)"
//        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_\(arch).01"
//        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/DriverKit/System/Library/dyld/dyld_shared_cache_\(arch)"
//        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/DriverKit/System/Library/dyld/dyld_shared_cache_\(arch).symbols"
        let url = URL(fileURLWithPath: path)

        self.cache = try! DyldCache(url: url)
    }

    func testHeader() throws {
        let header = cache.header
        print("Magic:", header.magic)
        print("UUID:", header.uuid)
        print("CacheType:", header.cacheType)
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
            if let fileSuffix = subCache.fileSuffix {
                print("File Suffix:", fileSuffix)
                print(
                    "Path:",
                    cache.url.path + fileSuffix
                )
            }
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

    func testDylibIndices() {
        let indices = cache.dylibIndices
            .sorted(by: { lhs, rhs in
                lhs.index < rhs.index
            })
        for index in indices {
            print(index.index, index.name)
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
        print("Relative Method Selector Base  Address Offset:", objcOptimization.relativeMethodSelectorBaseAddressOffset)
    }

    func testSwiftOptimization() throws {
        guard let swiftOptimization = cache.swiftOptimization else { return }
        print("Version:", swiftOptimization.version)
        print("Padding:", swiftOptimization.padding)
        print("Type Conformance Hash Table Cache Offset:", swiftOptimization.typeConformanceHashTableCacheOffset)
        print("Metadata Conformance Hash Table Cache Offset:", swiftOptimization.metadataConformanceHashTableCacheOffset)
        print("Foreign Type Conformance Hash Table Cache Offset:", swiftOptimization.foreignTypeConformanceHashTableCacheOffset)
    }
}
