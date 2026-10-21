//
//  OldObjCSelectorHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/21
//  
//

import Foundation
import MachOKitC

/// Precomputed selector table of `objc_opt_t` version 12 - 15. (`objc_selopt_t`)
///
/// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L349
public struct OldObjCSelectorHashTable: LayoutWrapper, OldObjCStringHashTableProtocol {
    public typealias Layout = objc_stringhash_t

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
    public let optimizationVersion: Int
}

extension OldObjCSelectorHashTable: _OldObjCStringHashTable, _ObjCSelectorHashTable {}

extension OldObjCSelectorHashTable {
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

    /// Sequence of selectors in the table
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
