//
//  OldObjCProtocolHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/21
//
//

import Foundation
import MachOKitC

/// Precomputed protocol table of `objc_opt_t` version 13 - 15. (`objc_protocolopt_t`)
///
/// Each name has exactly one protocol and no header info.
/// In the middle of version 15 it was replaced with ``OldObjCProtocolHashTable2``.
///
/// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L619
public struct OldObjCProtocolHashTable: LayoutWrapper, OldObjCStringHashTableProtocol {
    public typealias Layout = objc_stringhash_t

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
    public let optimizationVersion: Int
}

extension OldObjCProtocolHashTable: _OldObjCStringHashTable {}

public struct OldObjCProtocolHashTableEntry: Sendable {
    /// index of bucket in the hash table
    public let index: Int
    /// protocol name
    public let name: String
    /// offset of name from start address of main cache
    public let nameOffset: Int
    /// offset of protocol from start address of main cache
    public let offset: Int
}

extension OldObjCProtocolHashTable {
    /// Find protocol with the name
    /// - Parameters:
    ///   - name: protocol name
    ///   - cache: DyldCache to which `self` belongs
    /// - Returns: entry of found protocol
    public func entry(
        named name: String,
        in cache: DyldCache
    ) -> OldObjCProtocolHashTableEntry? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entry(named: name, reader: reader)
    }

    /// Find protocol with the name
    /// - Parameters:
    ///   - name: protocol name
    ///   - cache: FullDyldCache to which `self` belongs
    /// - Returns: entry of found protocol
    public func entry(
        named name: String,
        in cache: FullDyldCache
    ) -> OldObjCProtocolHashTableEntry? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entry(named: name, reader: reader)
    }

    /// Find protocol with the name
    /// - Parameters:
    ///   - name: protocol name
    ///   - cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: entry of found protocol
    public func entry(
        named name: String,
        in cache: DyldCacheLoaded
    ) -> OldObjCProtocolHashTableEntry? {
        _entry(named: name, reader: _reader(in: cache))
    }

    /// Sequence of entries in the table
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: DyldCache
    ) -> AnySequence<OldObjCProtocolHashTableEntry>? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entries(reader: reader)
    }

    /// Sequence of entries in the table
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: FullDyldCache
    ) -> AnySequence<OldObjCProtocolHashTableEntry>? {
        guard let reader = _reader(in: cache) else { return nil }
        return _entries(reader: reader)
    }

    /// Sequence of entries in the table
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: entries (empty buckets are skipped)
    public func entries(
        in cache: DyldCacheLoaded
    ) -> AnySequence<OldObjCProtocolHashTableEntry> {
        _entries(reader: _reader(in: cache))
    }
}

extension OldObjCProtocolHashTable {
    internal func _entry(
        named name: String,
        reader: some _ObjCHashTableReader
    ) -> OldObjCProtocolHashTableEntry? {
        let geometry = _geometry
        guard let index = geometry.index(of: name, reader: reader),
              let nameOffset = geometry.stringOffset(at: index, reader: reader),
              let protocolOffset = geometry.protocolOffset(at: index, reader: reader) else {
            return nil
        }
        return .init(
            index: index,
            name: name,
            nameOffset: offset + nameOffset,
            offset: offset + protocolOffset
        )
    }

    internal func _entry(
        at index: Int,
        geometry: _ObjCStringHashTableGeometry,
        reader: some _ObjCHashTableReader
    ) -> OldObjCProtocolHashTableEntry? {
        guard let nameOffset = geometry.stringOffset(at: index, reader: reader),
              let name = reader.readString(at: nameOffset),
              let protocolOffset = geometry.protocolOffset(at: index, reader: reader) else {
            return nil
        }
        return .init(
            index: index,
            name: name,
            nameOffset: offset + nameOffset,
            offset: offset + protocolOffset
        )
    }

    internal func _entries<Reader: _ObjCHashTableReader>(
        reader: Reader
    ) -> AnySequence<OldObjCProtocolHashTableEntry> {
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
    /// objc_protocolopt_t::getProtocol
    /// - Parameters:
    ///   - index: index of bucket
    ///   - reader: reader for the table
    /// - Returns: offset of protocol from start of the table
    func protocolOffset(
        at index: Int,
        reader: some _ObjCHashTableReader
    ) -> Int? {
        // int32_t protocolOffsets[capacity] follows the string hash table
        guard 0 <= index, index < capacity,
              let offset: Int32 = reader.read(
                at: stringHashTableEndOffset + index * MemoryLayout<Int32>.size
              ) else {
            return nil
        }
        return numericCast(offset)
    }
}
