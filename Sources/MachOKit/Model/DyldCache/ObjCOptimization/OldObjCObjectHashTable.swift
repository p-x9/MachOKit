//
//  OldObjCObjectHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/21
//
//

import Foundation
import MachOKitC

/// Precomputed table of classes or protocols of `objc_opt_t` version 12 - 15,
/// whose values are pairs of the object and its header info. (`objc_clsopt_t`)
///
/// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L391
public protocol OldObjCObjectHashTableProtocol: OldObjCStringHashTableProtocol {}

/// Implementation of class/protocol in the shared cache (`objc_classheader_t`)
public struct OldObjCHashTableObject: LayoutWrapper, Sendable {
    public typealias Layout = objc_classheader_t

    public var layout: Layout
    /// offset of the hash table from start address of main cache
    public let tableOffset: Int
}

extension OldObjCHashTableObject {
    /// Offset from start address of main cache to the Class/Protocol
    public var offset: Int {
        tableOffset + numericCast(layout.clsOffset)
    }

    /// Offset from start address of main cache to the header info (`objc_header_info_ro_t`)
    /// of the image containing the Class/Protocol
    public var headerInfoOffset: Int {
        tableOffset + numericCast(layout.hiOffset)
    }

    /// Index of the header info in the header optimization
    /// - Parameter headerOptimization: header optimization ro to which the header info belongs
    /// - Returns: index of header info
    public func headerInfoIndex(
        in headerOptimization: ObjCHeaderOptimizationRO64
    ) -> Int? {
        _headerInfoIndex(
            headerInfosOffset: headerOptimization.offset + headerOptimization.layoutSize,
            entrySize: headerOptimization.entrySize,
            count: headerOptimization.count
        )
    }

    /// Index of the header info in the header optimization
    /// - Parameter headerOptimization: header optimization ro to which the header info belongs
    /// - Returns: index of header info
    public func headerInfoIndex(
        in headerOptimization: ObjCHeaderOptimizationRO32
    ) -> Int? {
        _headerInfoIndex(
            headerInfosOffset: headerOptimization.offset + headerOptimization.layoutSize,
            entrySize: headerOptimization.entrySize,
            count: headerOptimization.count
        )
    }

    private func _headerInfoIndex(
        headerInfosOffset: Int,
        entrySize: Int,
        count: Int
    ) -> Int? {
        let distance = headerInfoOffset - headerInfosOffset
        guard entrySize > 0,
              distance >= 0,
              distance % entrySize == 0 else {
            return nil
        }
        let index = distance / entrySize
        guard index < count else { return nil }
        return index
    }
}

public struct OldObjCObjectHashTableEntry: Sendable {
    /// index of bucket in the hash table
    public let index: Int
    /// class/protocol name
    public let name: String
    /// offset of name from start address of main cache
    public let nameOffset: Int
    /// Implementations of the class/protocol
    ///
    /// Contains multiple values if the name appears in more than one image.
    public let objects: [OldObjCHashTableObject]
}

extension OldObjCObjectHashTableProtocol where Self: LayoutWrapper, Layout == objc_stringhash_t {
    /// Find class/protocol with the name
    /// - Parameters:
    ///   - name: class/protocol name
    ///   - cache: DyldCache to which `self` belongs
    /// - Returns: entry of found class/protocol
    public func entry(
        named name: String,
        in cache: DyldCache
    ) -> OldObjCObjectHashTableEntry? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entry(named: name, reader: reader)
    }

    /// Find class/protocol with the name
    /// - Parameters:
    ///   - name: class/protocol name
    ///   - cache: FullDyldCache to which `self` belongs
    /// - Returns: entry of found class/protocol
    public func entry(
        named name: String,
        in cache: FullDyldCache
    ) -> OldObjCObjectHashTableEntry? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entry(named: name, reader: reader)
    }

    /// Find class/protocol with the name
    /// - Parameters:
    ///   - name: class/protocol name
    ///   - cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: entry of found class/protocol
    public func entry(
        named name: String,
        in cache: DyldCacheLoaded
    ) -> OldObjCObjectHashTableEntry? {
        _entry(named: name, reader: _reader(in: cache))
    }
}

extension OldObjCObjectHashTableProtocol where Self: LayoutWrapper, Layout == objc_stringhash_t {
    /// Sequence of entries in the table
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: DyldCache
    ) -> AnySequence<OldObjCObjectHashTableEntry>? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entries(reader: reader)
    }

    /// Sequence of entries in the table
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: FullDyldCache
    ) -> AnySequence<OldObjCObjectHashTableEntry>? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entries(reader: reader)
    }

    /// Sequence of entries in the table
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: DyldCacheLoaded
    ) -> AnySequence<OldObjCObjectHashTableEntry> {
        _entries(reader: _reader(in: cache))
    }
}

extension OldObjCObjectHashTableProtocol where Self: LayoutWrapper, Layout == objc_stringhash_t {
    /// Number of objects stored in duplicate area
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: number of duplicates
    public func duplicateCount(in cache: DyldCache) -> Int? {
        guard let reader = _reader(in: cache) else { return nil }
        return _geometry.duplicateCount(reader: reader)
    }

    /// Number of objects stored in duplicate area
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: number of duplicates
    public func duplicateCount(in cache: FullDyldCache) -> Int? {
        guard let reader = _reader(in: cache) else { return nil }
        return _geometry.duplicateCount(reader: reader)
    }

    /// Number of objects stored in duplicate area
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: number of duplicates
    public func duplicateCount(in cache: DyldCacheLoaded) -> Int {
        _geometry.duplicateCount(reader: _reader(in: cache)) ?? 0
    }
}

extension OldObjCObjectHashTableProtocol where Self: LayoutWrapper, Layout == objc_stringhash_t {
    internal func _entry(
        named name: String,
        reader: some _ObjCHashTableReader
    ) -> OldObjCObjectHashTableEntry? {
        let geometry = _geometry
        guard let index = geometry.index(of: name, reader: reader),
              let nameOffset = geometry.stringOffset(at: index, reader: reader),
              let objects = geometry.classHeaders(at: index, tableOffset: offset, reader: reader) else {
            return nil
        }
        return .init(
            index: index,
            name: name,
            nameOffset: offset + nameOffset,
            objects: objects
        )
    }

    internal func _entry(
        at index: Int,
        geometry: _ObjCStringHashTableGeometry,
        reader: some _ObjCHashTableReader
    ) -> OldObjCObjectHashTableEntry? {
        guard let nameOffset = geometry.stringOffset(at: index, reader: reader),
              let name = reader.readString(at: nameOffset),
              let objects = geometry.classHeaders(at: index, tableOffset: offset, reader: reader) else {
            return nil
        }
        return .init(
            index: index,
            name: name,
            nameOffset: offset + nameOffset,
            objects: objects
        )
    }

    internal func _entries<Reader: _ObjCHashTableReader>(
        reader: Reader
    ) -> AnySequence<OldObjCObjectHashTableEntry> {
        let geometry = _geometry
        return AnySequence(
            (0 ..< capacity).lazy.compactMap {
                _entry(at: $0, geometry: geometry, reader: reader)
            }
        )
    }
}

// MARK: - Geometry

extension _ObjCStringHashTableGeometry {
    private typealias ClassHeader = objc_classheader_t

    /// objc_clsopt_t::getClassesAndHeaders
    /// - Parameters:
    ///   - index: index of bucket
    ///   - tableOffset: offset of the table from start address of main cache
    ///   - reader: reader for the table
    /// - Returns: implementations of the class/protocol in the bucket
    func classHeaders(
        at index: Int,
        tableOffset: Int,
        reader: some _ObjCHashTableReader
    ) -> [OldObjCHashTableObject]? {
        guard 0 <= index, index < capacity,
              let header = classHeader(
                at: objectOffsetsOffset + index * MemoryLayout<ClassHeader>.size,
                reader: reader
              ) else {
            return nil
        }

        if !header.isDuplicate {
            // class appears in exactly one header
            return [.init(layout: header, tableOffset: tableOffset)]
        }

        // class appears in more than one header
        let start = header.duplicateIndex
        let count = header.duplicateCount
        var objects: [OldObjCHashTableObject] = []
        objects.reserveCapacity(count)
        for i in start ..< start + count {
            guard let header = classHeader(
                at: duplicateOffsetsOffset + i * MemoryLayout<ClassHeader>.size,
                reader: reader
            ) else {
                return nil
            }
            objects.append(.init(layout: header, tableOffset: tableOffset))
        }
        return objects
    }

    private func classHeader(
        at offset: Int,
        reader: some _ObjCHashTableReader
    ) -> ClassHeader? {
        guard let clsOffset: Int32 = reader.read(at: offset),
              let hiOffset: Int32 = reader.read(at: offset + MemoryLayout<Int32>.size) else {
            return nil
        }
        return .init(clsOffset: clsOffset, hiOffset: hiOffset)
    }
}

// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L378-L388
extension objc_classheader_t {
    // For duplicate class names:
    // clsOffset = count<<1 | 1
    // duplicated classes are duplicateOffsets[hiOffset..hiOffset+count-1]
    var isDuplicate: Bool {
        clsOffset & 1 != 0
    }

    var duplicateCount: Int {
        numericCast(UInt32(bitPattern: clsOffset) >> 1)
    }

    var duplicateIndex: Int {
        numericCast(hiOffset)
    }
}
