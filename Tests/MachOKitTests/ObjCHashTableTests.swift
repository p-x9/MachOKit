//
//  ObjCHashTableTests.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/20
//
//

import XCTest
@testable import MachOKit

#if canImport(Darwin)

final class ObjCHashTableTests: XCTestCase {
    var cache: DyldCacheLoaded!

    override func setUp() {
        var size = 0
        guard let ptr = _dyld_get_shared_cache_range(&size) else {
            return
        }
        cache = try? .init(ptr: ptr)
    }

    func testSelectorHashTable() throws {
        let cache = try XCTUnwrap(cache)
        let objcOptimization = try XCTUnwrap(cache.objcOptimization)
        let table = try XCTUnwrap(objcOptimization.selectorHashTable(in: cache))

        // Selectors in the shared cache are uniqued with the table.
        for name in ["alloc", "init", "description", "isEqual:"] {
            let entry = try XCTUnwrap(table.selector(named: name, in: cache), name)
            XCTAssertEqual(entry.name, name)
            XCTAssertEqual(
                cache.ptr.advanced(by: entry.offset),
                unsafeBitCast(NSSelectorFromString(name), to: UnsafeRawPointer.self),
                name
            )
        }

        XCTAssertNil(table.selector(named: "thisSelectorShouldNotExist:", in: cache))
    }

    func testClassHashTable() throws {
        let cache = try XCTUnwrap(cache)
        let objcOptimization = try XCTUnwrap(cache.objcOptimization)
        let table = try XCTUnwrap(objcOptimization.classHashTable(in: cache))

        let headerInfos = try XCTUnwrap(
            objcOptimization.headerOptimizationRO64(in: cache)?.headerInfos(in: cache)
        )

        let classes: [(name: String, imagePath: String)] = [
            ("NSObject", "/usr/lib/libobjc.A.dylib"),
            ("NSString", "/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation"),
            ("NSArray", "/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation")
        ]
        for (name, imagePath) in classes {
            let entry = try XCTUnwrap(table.entry(named: name, in: cache), name)
            XCTAssertEqual(entry.name, name)
            let object = try XCTUnwrap(entry.objects.first, name)

            // The value points to the class object itself.
            let classPointer = cache.ptr.advanced(by: object.offset)
            XCTAssertEqual(symbolName(at: classPointer), "OBJC_CLASS_$_\(name)")

            // dylibObjCIndex is the index of header infos.
            let headerInfo = try XCTUnwrap(
                headerInfos.first(where: { $0.index == object.dylibObjCIndex }),
                name
            )
            XCTAssertEqual(headerInfo.machO(in: cache)?.path, imagePath)
        }

        XCTAssertNil(table.entry(named: "ThisClassShouldNotExist", in: cache))
        XCTAssertGreaterThanOrEqual(table.classCount(in: cache), table.occupied)
    }

    func testProtocolHashTable() throws {
        let cache = try XCTUnwrap(cache)
        let objcOptimization = try XCTUnwrap(cache.objcOptimization)
        let table = try XCTUnwrap(objcOptimization.protocolHashTable(in: cache))

        let entry = try XCTUnwrap(table.entry(named: "NSObject", in: cache))
        XCTAssertEqual(entry.name, "NSObject")
        XCTAssertFalse(entry.objects.isEmpty)

        // The runtime uses the preoptimized protocol in the shared cache.
        let runtimeProtocol = try XCTUnwrap(objc_getProtocol("NSObject"))
        XCTAssertTrue(
            entry.objects.allSatisfy {
                cache.ptr.advanced(by: $0.offset) == unsafeBitCast(runtimeProtocol, to: UnsafeRawPointer.self)
            }
        )

        XCTAssertNil(table.entry(named: "ThisProtocolShouldNotExist", in: cache))
    }

    func testEntriesAreConsistentWithLookup() throws {
        let cache = try XCTUnwrap(cache)
        let objcOptimization = try XCTUnwrap(cache.objcOptimization)
        let table = try XCTUnwrap(objcOptimization.protocolHashTable(in: cache))

        let entries = Array(table.entries(in: cache))
        XCTAssertEqual(entries.count, table.occupied)
        for entry in entries.prefix(500) {
            let found = try XCTUnwrap(table.entry(named: entry.name, in: cache), entry.name)
            XCTAssertEqual(found.index, entry.index)
            XCTAssertEqual(found.objects.count, entry.objects.count)
        }
    }

    func testFileBackedCacheMatchesLoadedCache() throws {
        let cache = try XCTUnwrap(cache)
        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e"
        guard let fullCache = try? FullDyldCache(url: URL(fileURLWithPath: path)),
              fullCache.header.uuid == cache.header.uuid else {
            throw XCTSkip("On-disk cache is not the loaded one")
        }

        let loadedOptimization = try XCTUnwrap(cache.objcOptimization)
        let fileOptimization = try XCTUnwrap(fullCache.objcOptimization)

        let loadedSelectors = try XCTUnwrap(loadedOptimization.selectorHashTable(in: cache))
        let fileSelectors = try XCTUnwrap(fileOptimization.selectorHashTable(in: fullCache))
        XCTAssertEqual(loadedSelectors.offset, fileSelectors.offset)
        XCTAssertEqual(loadedSelectors.occupied, fileSelectors.occupied)
        for name in ["alloc", "init", "description"] {
            XCTAssertEqual(
                loadedSelectors.selector(named: name, in: cache)?.offset,
                fileSelectors.selector(named: name, in: fullCache)?.offset,
                name
            )
        }

        let loadedClasses = try XCTUnwrap(loadedOptimization.classHashTable(in: cache))
        let fileClasses = try XCTUnwrap(fileOptimization.classHashTable(in: fullCache))
        XCTAssertEqual(loadedClasses.classCount(in: cache), fileClasses.classCount(in: fullCache))
        for name in ["NSObject", "NSString"] {
            XCTAssertEqual(
                loadedClasses.entry(named: name, in: cache)?.objects.map(\.offset),
                fileClasses.entry(named: name, in: fullCache)?.objects.map(\.offset),
                name
            )
        }
    }
}

extension ObjCHashTableTests {
    private func symbolName(at pointer: UnsafeRawPointer) -> String? {
        var info = Dl_info()
        guard dladdr(pointer, &info) != 0,
              info.dli_saddr == UnsafeMutableRawPointer(mutating: pointer),
              let name = info.dli_sname else {
            return nil
        }
        return String(cString: name)
    }
}

#endif
