import XCTest
@_spi(Support) @testable import MachOKit
import MachOKitC

final class FullDyldCacheLocateValueTests: XCTestCase {
    private func withCache(_ body: (FullDyldCache, URL) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("dyld_shared_cache_arm64e")
        let uuids = (0..<3).map { _ in UUID() }
        for index in 0..<3 {
            var header = dyld_cache_header()
            withUnsafeMutableBytes(of: &header.magic) { bytes in
                for (i, byte) in "dyld_v1  arm64e".utf8.enumerated() { bytes[i] = byte }
            }
            header.mappingOffset = 0x238
            header.cputype = CPU_TYPE_ARM64
            header.cpusubtype = CPU_SUBTYPE_ARM64E
            header.uuid = uuids[index].uuid
            if index == 0 {
                header.subCacheArrayOffset = 0x400
                header.subCacheArrayCount = 2
            }
            var data = Data(repeating: 0, count: 16384)
            withUnsafeBytes(of: &header) { data.replaceSubrange(0..<$0.count, with: $0) }
            if index == 0 {
                for subIndex in 1...2 {
                    var entry = dyld_subcache_entry()
                    entry.uuid = uuids[subIndex].uuid
                    withUnsafeMutableBytes(of: &entry.fileSuffix) { bytes in
                        for (i, byte) in String(format: ".%02d", subIndex).utf8.enumerated() { bytes[i] = byte }
                    }
                    let offset = 0x400 + (subIndex - 1) * MemoryLayout<dyld_subcache_entry>.size
                    withUnsafeBytes(of: &entry) { data.replaceSubrange(offset..<(offset + $0.count), with: $0) }
                }
            }
            let path = index == 0 ? url : URL(fileURLWithPath: url.path + String(format: ".%02d", index))
            try data.write(to: path)
        }
        try body(FullDyldCache(url: url), directory)
    }

    func testReceiverFirstAndEachRemainingCacheOnceWithoutReopeningFiles() throws {
        try withCache { full, _ in
            let caches = full.allCaches
            let receiver = caches[1]
            // Already mapped files remain readable after unlinking. A path-based
            // fallback would fail, proving this uses the FullDyldCache handles.
            for url in full.urls { try FileManager.default.removeItem(at: url) }
            var visited: [UUID] = []
            let result: DyldCache.LocatedValue<Int>? = try receiver.locateValue {
                visited.append($0.header.uuid)
                return $0.header.uuid == caches[2].header.uuid ? 42 : nil
            }
            XCTAssertEqual(result?.value, 42)
            XCTAssertEqual(result?.cache.header.uuid, caches[2].header.uuid)
            XCTAssertEqual(visited, [caches[1], caches[0], caches[2]].map { $0.header.uuid })
            XCTAssertNil(full.locateValue { _ -> Int? in nil })
            XCTAssertEqual(full.locateValue(\.cpu)?.cache.header.uuid, caches[0].header.uuid)
        }
    }

    func testResolverErrorIsPropagated() throws {
        enum Failure: Error { case expected }
        try withCache { full, _ in
            let receiver = full.subCaches[0]
            var calls = 0
            XCTAssertThrowsError(try receiver.locateValue { cache -> Int? in
                calls += 1
                if cache.header.uuid == full.header.uuid { throw Failure.expected }
                return nil
            }) { XCTAssertTrue($0 is Failure) }
            XCTAssertEqual(calls, 2)
        }
    }
}
