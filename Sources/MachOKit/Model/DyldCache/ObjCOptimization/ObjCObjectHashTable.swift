//
//  ObjCObjectHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/20
//
//

import Foundation
import MachOKitC

/// Precomputed table of classes or protocols.
///
/// The keys are class/protocol names, and the values are the
/// implementations in the shared cache.
///
/// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/OptimizerObjC.h#L269
public protocol ObjCObjectHashTableProtocol: ObjCStringHashTableProtocol {}

/// Implementation of class/protocol in the shared cache
public struct ObjCHashTableObject: LayoutWrapper, Sendable {
    public typealias Layout = objc_object_hash_table_object

    public var layout: Layout
}

extension ObjCHashTableObject {
    /// Offset from start address of main cache to the Class/Protocol
    public var offset: Int {
        numericCast(layout.objectCacheOffset)
    }

    /// Index of the image containing the Class/Protocol
    ///
    /// It is the index of header infos in `ObjCHeaderOptimizationRO` and `ObjCHeaderOptimizationRW`.
    public var dylibObjCIndex: Int {
        numericCast(layout.dylibObjCIndex)
    }
}

public struct ObjCObjectHashTableEntry: Sendable {
    /// index of bucket in the hash table
    public let index: Int
    /// class/protocol name
    public let name: String
    /// offset of name from start address of main cache
    public let nameOffset: Int
    /// Implementations of the class/protocol
    ///
    /// Contains multiple values if the name appears in more than one image.
    public let objects: [ObjCHashTableObject]
}

extension ObjCObjectHashTableProtocol where Self: LayoutWrapper, Layout == objc_string_hash_table {
    /// Find class/protocol with the name
    /// - Parameters:
    ///   - name: class/protocol name
    ///   - cache: DyldCache to which `self` belongs
    /// - Returns: entry of found class/protocol
    public func entry(
        named name: String,
        in cache: DyldCache
    ) -> ObjCObjectHashTableEntry? {
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
    ) -> ObjCObjectHashTableEntry? {
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
    ) -> ObjCObjectHashTableEntry? {
        _entry(named: name, reader: _reader(in: cache))
    }
}

extension ObjCObjectHashTableProtocol where Self: LayoutWrapper, Layout == objc_string_hash_table {
    /// Sequence of entries in the table
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: DyldCache
    ) -> AnySequence<ObjCObjectHashTableEntry>? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entries(reader: reader)
    }

    /// Sequence of entries in the table
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: FullDyldCache
    ) -> AnySequence<ObjCObjectHashTableEntry>? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entries(reader: reader)
    }

    /// Sequence of entries in the table
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: DyldCacheLoaded
    ) -> AnySequence<ObjCObjectHashTableEntry> {
        _entries(reader: _reader(in: cache))
    }
}

extension ObjCObjectHashTableProtocol where Self: LayoutWrapper, Layout == objc_string_hash_table {
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

extension ObjCObjectHashTableProtocol where Self: LayoutWrapper, Layout == objc_string_hash_table {
    internal func _entry(
        named name: String,
        reader: some _ObjCHashTableReader
    ) -> ObjCObjectHashTableEntry? {
        let geometry = _geometry
        guard let index = geometry.index(of: name, reader: reader),
              let nameOffset = geometry.stringOffset(at: index, reader: reader),
              let objects = geometry.objects(at: index, reader: reader) else {
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
    ) -> ObjCObjectHashTableEntry? {
        guard let nameOffset = geometry.stringOffset(at: index, reader: reader),
              let name = reader.readString(at: nameOffset),
              let objects = geometry.objects(at: index, reader: reader) else {
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
    ) -> AnySequence<ObjCObjectHashTableEntry> {
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
    private typealias ObjectData = UInt64

    /// offset of `objectOffsets[capacity]` from start of the table
    var objectOffsetsOffset: Int {
        stringHashTableEndOffset
    }

    /// offset of `duplicateCount` from start of the table
    var duplicateCountOffset: Int {
        objectOffsetsOffset + capacity * MemoryLayout<ObjectData>.size
    }

    /// offset of `duplicateOffsets[duplicateCount]` from start of the table
    var duplicateOffsetsOffset: Int {
        duplicateCountOffset + MemoryLayout<UInt32>.size
    }

    func duplicateCount(
        reader: some _ObjCHashTableReader
    ) -> Int? {
        guard let count: UInt32 = reader.read(at: duplicateCountOffset) else {
            return nil
        }
        return numericCast(count)
    }

    /// ObjectHashTable::forEachObject
    /// - Parameters:
    ///   - index: index of bucket
    ///   - reader: reader for the table
    /// - Returns: implementations of the class/protocol in the bucket
    func objects(
        at index: Int,
        reader: some _ObjCHashTableReader
    ) -> [ObjCHashTableObject]? {
        guard 0 <= index, index < capacity,
              let raw: ObjectData = reader.read(
                at: objectOffsetsOffset + index * MemoryLayout<ObjectData>.size
              ) else {
            return nil
        }

        let object: objc_object_hash_table_object = autoBitCast(raw)
        if object.isDuplicate == 0 {
            // object appears in exactly one header
            return [.init(layout: object)]
        }

        // object appears in more than one header
        let duplicate: objc_object_hash_table_duplicate = autoBitCast(raw)
        let start: Int = numericCast(duplicate.index)
        let count: Int = numericCast(duplicate.count)
        var objects: [ObjCHashTableObject] = []
        objects.reserveCapacity(count)
        for i in start ..< start + count {
            guard let raw: ObjectData = reader.read(
                at: duplicateOffsetsOffset + i * MemoryLayout<ObjectData>.size
            ) else {
                return nil
            }
            objects.append(.init(layout: autoBitCast(raw)))
        }
        return objects
    }
}
