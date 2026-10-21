//
//  ObjCSelectorHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/20
//
//

import Foundation
import MachOKitC

/// Precomputed selector table.
///
/// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/OptimizerObjC.h#L229
public struct ObjCSelectorHashTable: LayoutWrapper, ObjCStringHashTableProtocol {
    public typealias Layout = objc_string_hash_table

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
}

public struct ObjCSelectorHashTableEntry: Sendable {
    /// index of bucket in the hash table
    public let index: Int
    /// selector name
    public let name: String
    /// offset of selector name from start address of main cache
    public let offset: Int
}

extension ObjCSelectorHashTable {
    /// Find uniqued selector with the name
    /// - Parameters:
    ///   - name: selector name
    ///   - cache: DyldCache to which `self` belongs
    /// - Returns: entry of found selector
    public func selector(
        named name: String,
        in cache: DyldCache
    ) -> ObjCSelectorHashTableEntry? {
        guard let reader = _reader(in: cache) else { return nil }
        return _selector(named: name, reader: reader)
    }

    /// Find uniqued selector with the name
    /// - Parameters:
    ///   - name: selector name
    ///   - cache: FullDyldCache to which `self` belongs
    /// - Returns: entry of found selector
    public func selector(
        named name: String,
        in cache: FullDyldCache
    ) -> ObjCSelectorHashTableEntry? {
        guard let reader = _reader(in: cache) else { return nil }
        return _selector(named: name, reader: reader)
    }

    /// Find uniqued selector with the name
    /// - Parameters:
    ///   - name: selector name
    ///   - cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: entry of found selector
    public func selector(
        named name: String,
        in cache: DyldCacheLoaded
    ) -> ObjCSelectorHashTableEntry? {
        _selector(named: name, reader: _reader(in: cache))
    }
}

extension ObjCSelectorHashTable {
    /// Sequence of selectors in the table
    ///
    /// Entries whose names are not contained in `cache` are skipped.
    /// Use `FullDyldCache` to read names placed in other subcaches.
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: selectors (empty buckets are skipped)
    public func selectors(
        in cache: DyldCache
    ) -> AnySequence<ObjCSelectorHashTableEntry>? {
        guard let reader = _reader(in: cache) else { return nil }
        return _selectors(reader: reader)
    }

    /// Sequence of selectors in the table
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: selectors (empty buckets are skipped)
    public func selectors(
        in cache: FullDyldCache
    ) -> AnySequence<ObjCSelectorHashTableEntry>? {
        guard let reader = _reader(in: cache) else { return nil }
        return _selectors(reader: reader)
    }

    /// Sequence of selectors in the table
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: selectors (empty buckets are skipped)
    public func selectors(
        in cache: DyldCacheLoaded
    ) -> AnySequence<ObjCSelectorHashTableEntry> {
        _selectors(reader: _reader(in: cache))
    }
}

extension ObjCSelectorHashTable: _ObjCSelectorHashTable {}

// MARK: - Shared implementation

/// Selector tables sharing the lookup and enumeration logic between formats
internal protocol _ObjCSelectorHashTable: ObjCStringHashTableProtocol {
    var _geometry: _ObjCStringHashTableGeometry { get }
}

extension _ObjCSelectorHashTable {
    internal func _selector(
        named name: String,
        reader: some _ObjCHashTableReader
    ) -> ObjCSelectorHashTableEntry? {
        let geometry = _geometry
        guard let index = geometry.index(of: name, reader: reader),
              let stringOffset = geometry.stringOffset(at: index, reader: reader) else {
            return nil
        }
        return .init(
            index: index,
            name: name,
            offset: offset + stringOffset
        )
    }

    internal func _selector(
        at index: Int,
        geometry: _ObjCStringHashTableGeometry,
        reader: some _ObjCHashTableReader
    ) -> ObjCSelectorHashTableEntry? {
        guard let stringOffset = geometry.stringOffset(at: index, reader: reader),
              let name = reader.readString(at: stringOffset) else {
            return nil
        }
        return .init(
            index: index,
            name: name,
            offset: offset + stringOffset
        )
    }

    internal func _selectors<Reader: _ObjCHashTableReader>(
        reader: Reader
    ) -> AnySequence<ObjCSelectorHashTableEntry> {
        let geometry = _geometry
        return AnySequence(
            (0 ..< capacity).lazy.compactMap {
                _selector(at: $0, geometry: geometry, reader: reader)
            }
        )
    }
}
