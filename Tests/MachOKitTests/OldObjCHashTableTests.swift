//
//  OldObjCHashTableTests.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/21
//
//

import XCTest
@testable import MachOKit
import MachOKitC

/// Tests for hash tables of `objc_opt_t` version 12 - 15 using synthetic tables,
/// since caches with these formats are not available on recent OSes.
final class OldObjCHashTableTests: XCTestCase {
    /// offset of the synthetic table from start address of main cache
    let tableOffset = 0x1000

    func testObjCOpt15Layout() {
        XCTAssertEqual(MemoryLayout<objc_opt_t_15>.offset(of: \.protocolopt2_offset), 28)
        XCTAssertEqual(MemoryLayout<objc_stringhash_t>.size, MemoryLayout<objc_string_hash_table>.size)
    }

    func testSelectorTable() throws {
        for version in [12, 13, 15] {
            let keys = ["alloc", "init", "description"]
            let synthetic = SyntheticTable(version: version, keys: keys, values: .none)
            let table = OldObjCSelectorHashTable(
                layout: synthetic.layout,
                offset: tableOffset,
                optimizationVersion: version
            )

            try synthetic.withReader { reader in
                for key in keys {
                    let entry = try XCTUnwrap(table._selector(named: key, reader: reader), "\(key) v\(version)")
                    XCTAssertEqual(entry.name, key)
                    XCTAssertEqual(entry.offset, tableOffset + synthetic.stringOffsets[key]!)
                }
                XCTAssertNil(table._selector(named: "release", reader: reader))

                // Empty buckets are skipped (version 12 marks them with the offset of `zero`)
                let selectors = Array(table._selectors(reader: reader))
                XCTAssertEqual(Set(selectors.map(\.name)), Set(keys), "v\(version)")
            }
        }
    }

    func testClassTable() throws {
        var headerOptimizationLayout = objc_headeropt_ro_t_64()
        headerOptimizationLayout.count = 3
        headerOptimizationLayout.entsize = 16
        let headerOptimization = ObjCHeaderOptimizationRO64(
            layout: headerOptimizationLayout,
            offset: 0x800
        )
        // offset of header info at index from start of the table
        func headerInfo(_ index: Int) -> Int32 {
            Int32(headerOptimization.offset + headerOptimization.layoutSize + 16 * index - tableOffset)
        }

        for version in [12, 13, 15] {
            let values: [String: [objc_classheader_t]] = [
                "NSObject": [.init(clsOffset: 0x200, hiOffset: headerInfo(0))],
                "NSString": [
                    .init(clsOffset: 0x300, hiOffset: headerInfo(1)),
                    .init(clsOffset: 0x400, hiOffset: headerInfo(2))
                ],
                "NSArray": [.init(clsOffset: -0x500, hiOffset: headerInfo(2))]
            ]
            let synthetic = SyntheticTable(version: version, keys: Array(values.keys), values: .classes(values))
            let table = OldObjCClassHashTable(
                layout: synthetic.layout,
                offset: tableOffset,
                optimizationVersion: version
            )

            try synthetic.withReader { reader in
                for (name, headers) in values {
                    let entry = try XCTUnwrap(table._entry(named: name, reader: reader), "\(name) v\(version)")
                    XCTAssertEqual(entry.nameOffset, tableOffset + synthetic.stringOffsets[name]!)
                    XCTAssertEqual(entry.objects.map(\.offset), headers.map { tableOffset + Int($0.clsOffset) })
                    XCTAssertEqual(entry.objects.map(\.headerInfoOffset), headers.map { tableOffset + Int($0.hiOffset) })
                }

                let string = try XCTUnwrap(table._entry(named: "NSString", reader: reader))
                XCTAssertEqual(string.objects.map { $0.headerInfoIndex(in: headerOptimization) }, [1, 2])

                XCTAssertNil(table._entry(named: "NSDictionary", reader: reader))
                XCTAssertEqual(table._geometry.duplicateCount(reader: reader), 2)
                XCTAssertEqual(Set(table._entries(reader: reader).map(\.name)), Set(values.keys))
            }
        }
    }

    func testProtocolTable() throws {
        for version in [13, 15] {
            let values: [String: Int32] = [
                "NSObject": 0x200,
                "NSCopying": 0x280,
                "NSCoding": -0x300
            ]
            let synthetic = SyntheticTable(version: version, keys: Array(values.keys), values: .protocols(values))
            let table = OldObjCProtocolHashTable(
                layout: synthetic.layout,
                offset: tableOffset,
                optimizationVersion: version
            )

            try synthetic.withReader { reader in
                for (name, offset) in values {
                    let entry = try XCTUnwrap(table._entry(named: name, reader: reader), "\(name) v\(version)")
                    XCTAssertEqual(entry.offset, tableOffset + Int(offset))
                }
                XCTAssertNil(table._entry(named: "NSSecureCoding", reader: reader))
                XCTAssertEqual(Set(table._entries(reader: reader).map(\.name)), Set(values.keys))
            }
        }
    }
}

// MARK: - Synthetic table

/// Builds a minimal `objc_stringhash_t` based table.
///
/// `mask` is 0 and `scramble` is all zero, so the bucket index is `lookup8(key, salt) >> shift`.
/// A salt that maps each key to a distinct bucket is searched.
private struct SyntheticTable {
    enum Values {
        case none
        case classes([String: [objc_classheader_t]])
        case protocols([String: Int32])
    }

    let layout: objc_stringhash_t
    let bytes: [UInt8]
    /// offsets of strings from start of the table
    let stringOffsets: [String: Int]

    init(version: Int, keys: [String], values: Values) {
        let capacity = 4
        let shift: UInt32 = 62
        precondition(keys.count < capacity) // keep an empty bucket

        var salt: UInt64 = 0
        var indices: [String: Int] = [:]
        repeat {
            salt += 1
            indices = Dictionary(uniqueKeysWithValues: keys.map {
                ($0, Int(PerfectHash.lookup8($0, level: salt) >> shift))
            })
        } while Set(indices.values).count != keys.count

        var layout = objc_stringhash_t()
        layout.capacity = UInt32(capacity)
        layout.occupied = UInt32(keys.count)
        layout.shift = shift
        layout.mask = 0
        layout.salt = salt
        self.layout = layout

        let headerSize = MemoryLayout<objc_stringhash_t>.size
        let emptyStringOffset: Int32 = version == 12
            ? Int32(MemoryLayout<objc_stringhash_t>.offset(of: \.unused1)!)
            : 0

        // tab[mask+1], checkbytes[capacity], offsets[capacity]
        let tabSize = 1
        let checkBytesOffset = headerSize + tabSize
        let stringOffsetsOffset = checkBytesOffset + capacity
        let valuesOffset = stringOffsetsOffset + 4 * capacity

        var valuesBytes: [UInt8] = []
        switch values {
        case .none:
            break
        case let .classes(classes):
            var headers = [objc_classheader_t](repeating: .init(clsOffset: 0, hiOffset: 0), count: capacity)
            var duplicates: [objc_classheader_t] = []
            for (name, list) in classes {
                let index = indices[name]!
                if list.count == 1 {
                    headers[index] = list[0]
                } else {
                    headers[index] = .init(
                        clsOffset: Int32(list.count << 1 | 1),
                        hiOffset: Int32(duplicates.count)
                    )
                    duplicates += list
                }
            }
            for header in headers {
                valuesBytes += Self.bytes(of: header.clsOffset) + Self.bytes(of: header.hiOffset)
            }
            valuesBytes += Self.bytes(of: UInt32(duplicates.count))
            for header in duplicates {
                valuesBytes += Self.bytes(of: header.clsOffset) + Self.bytes(of: header.hiOffset)
            }
        case let .protocols(protocols):
            var offsets = [Int32](repeating: 0, count: capacity)
            for (name, offset) in protocols {
                offsets[indices[name]!] = offset
            }
            for offset in offsets {
                valuesBytes += Self.bytes(of: offset)
            }
        }

        var checkBytes = [UInt8](repeating: 0, count: capacity)
        var stringOffsetsList = [Int32](repeating: emptyStringOffset, count: capacity)
        var strings: [UInt8] = []
        var stringOffsets: [String: Int] = [:]
        let stringsOffset = valuesOffset + valuesBytes.count
        for key in keys {
            let index = indices[key]!
            let utf8 = Array(key.utf8)
            checkBytes[index] = ((utf8[0] & 0x7) << 5) | (UInt8(truncatingIfNeeded: utf8.count) & 0x1f)
            let offset = stringsOffset + strings.count
            stringOffsetsList[index] = Int32(offset)
            stringOffsets[key] = offset
            strings += utf8 + [0]
        }
        self.stringOffsets = stringOffsets

        var bytes = withUnsafeBytes(of: layout) { Array($0) }
        bytes += [UInt8](repeating: 0, count: tabSize)
        bytes += checkBytes
        for offset in stringOffsetsList {
            bytes += Self.bytes(of: offset)
        }
        bytes += valuesBytes
        bytes += strings
        precondition(bytes.count == stringsOffset + strings.count)
        self.bytes = bytes
    }

    func withReader(_ body: (_ObjCHashTableMemoryReader) throws -> Void) rethrows {
        try bytes.withUnsafeBytes {
            try body(.init(basePointer: $0.baseAddress!))
        }
    }

    private static func bytes<T: FixedWidthInteger>(of value: T) -> [UInt8] {
        withUnsafeBytes(of: value.littleEndian) { Array($0) }
    }
}
