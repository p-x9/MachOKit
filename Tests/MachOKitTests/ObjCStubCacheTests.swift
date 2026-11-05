import XCTest
import MachOKitC
@_spi(Support) @testable import MachOKit

final class ObjCStubCacheTests: XCTestCase {
    private let base: UInt64 = 0x180000000

    private func withFixture(
        slotCache: Int,
        stringCache: Int,
        encoded: Bool,
        targetIsNull: Bool = false,
        useFullCache: Bool,
        body: (MachOFile, ObjCStub) throws -> Void
    ) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("dyld_shared_cache_arm64e")
        let uuids = (0..<4).map { _ in UUID() }
        let target = base + UInt64(stringCache * 0x10000 + 0x1800)
        for index in 0..<4 {
            var data = Data(repeating: 0, count: 16384)
            var header = dyld_cache_header()
            withUnsafeMutableBytes(of: &header.magic) { bytes in
                for (i, byte) in "dyld_v1  arm64e".utf8.enumerated() { bytes[i] = byte }
            }
            header.uuid = uuids[index].uuid
            header.cputype = CPU_TYPE_ARM64
            header.cpusubtype = CPU_SUBTYPE_ARM64E
            header.sharedRegionStart = base
            header.mappingOffset = 0x300
            header.mappingCount = 1
            header.mappingWithSlideOffset = 0x340
            header.mappingWithSlideCount = 1
            if index == 0 {
                header.subCacheArrayOffset = 0x400
                header.subCacheArrayCount = 3
            }
            store(header, at: 0, in: &data)
            var mapping = dyld_cache_mapping_info()
            mapping.address = base + UInt64(index * 0x10000)
            mapping.size = UInt64(data.count)
            store(mapping, at: 0x300, in: &data)
            var slideMapping = dyld_cache_mapping_and_slide_info()
            slideMapping.address = mapping.address
            slideMapping.size = mapping.size
            if index == slotCache && encoded {
                var slide = dyld_cache_slide_info5()
                slide.version = 5
                slide.page_size = 16384
                slide.page_starts_count = 1
                slide.value_add = base
                slideMapping.slideInfoFileOffset = 0x600
                slideMapping.slideInfoFileSize = UInt64(MemoryLayout.size(ofValue: slide) + 2)
                store(slide, at: 0x600, in: &data)
                store(UInt16(0x1000 / 8), at: 0x600 + MemoryLayout.size(ofValue: slide), in: &data)
            }
            store(slideMapping, at: 0x340, in: &data)
            if index == 0 {
                for subIndex in 1...3 {
                    var entry = dyld_subcache_entry()
                    entry.uuid = uuids[subIndex].uuid
                    entry.cacheVMOffset = UInt64(subIndex * 0x10000)
                    withUnsafeMutableBytes(of: &entry.fileSuffix) { bytes in
                        for (i, byte) in String(format: ".%02d", subIndex).utf8.enumerated() { bytes[i] = byte }
                    }
                    store(entry, at: 0x400 + (subIndex - 1) * MemoryLayout.size(ofValue: entry), in: &data)
                }
            }
            if index == 1 {
                var machHeader = mach_header_64()
                machHeader.magic = MH_MAGIC_64
                machHeader.cputype = CPU_TYPE_ARM64
                machHeader.cpusubtype = CPU_SUBTYPE_ARM64E
                machHeader.filetype = UInt32(MH_DYLIB)
                store(machHeader, at: 0x800, in: &data)
            }
            if index == slotCache {
                let pointer = targetIsNull ? 0 : (encoded ? target - base : target)
                store(pointer, at: 0x1000, in: &data)
            }
            if index == stringCache {
                let string = Data("setObject:forKey:\0".utf8)
                data.replaceSubrange(0x1800..<(0x1800 + string.count), with: string)
            }
            let fileURL = index == 0 ? url : URL(fileURLWithPath: url.path + String(format: ".%02d", index))
            try data.write(to: fileURL)
        }
        let cache: DyldCache
        if useFullCache {
            cache = try FullDyldCache(url: url).subCaches[0]
        } else {
            let main = try DyldCache(url: url)
            cache = try DyldCache(subcacheUrl: URL(fileURLWithPath: url.path + ".01"), mainCache: main)
        }
        let image = try MachOFile(url: cache.url, imagePath: "/fixture.dylib", headerStartOffsetInCache: 0x800, cache: cache)
        let stub = ObjCStub(
            stub: .init(rawData: Data(), address: base + 0x10800, indirectSymbolIndex: nil, branch: .unknown),
            selectorReference: base + UInt64(slotCache * 0x10000 + 0x1000)
        )
        try body(image, stub)
        XCTAssertEqual(image._cachedFullCache != nil, useFullCache)
    }

    private func store<T>(_ value: T, at offset: Int, in data: inout Data) {
        var value = value
        withUnsafeBytes(of: &value) { data.replaceSubrange(offset..<(offset + $0.count), with: $0) }
    }

    func testSeparateHeaderSlotAndStringCaches() throws {
        for full in [false, true] {
            try withFixture(slotCache: 2, stringCache: 3, encoded: true, useFullCache: full) { image, stub in
                XCTAssertEqual(stub.selector(in: image), "setObject:forKey:")
            }
        }
    }

    func testSameCacheAndRawPointer() throws {
        try withFixture(slotCache: 1, stringCache: 1, encoded: false, useFullCache: false) { image, stub in
            XCTAssertEqual(stub.selector(in: image), "setObject:forKey:")
        }
    }

    func testNullAndMissingReferences() throws {
        try withFixture(slotCache: 2, stringCache: 3, encoded: true, targetIsNull: true, useFullCache: false) { image, stub in
            XCTAssertNil(stub.selector(in: image))
            XCTAssertNil(ObjCStub(stub: stub.stub, selectorReference: nil).selector(in: image))
            XCTAssertNil(ObjCStub(stub: stub.stub, selectorReference: 0xdeadbeef).selector(in: image))
        }
    }
}
