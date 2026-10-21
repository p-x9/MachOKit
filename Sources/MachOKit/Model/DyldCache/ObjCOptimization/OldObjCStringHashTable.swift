//
//  OldObjCStringHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/21
//
//

import Foundation
import MachOKitC

/// Precomputed perfect hash table of strings used by `objc_opt_t` version 12 - 15.
///
/// The hash function and the placement of `tab`, `checkbytes` and `offsets` are the same as
/// ``ObjCStringHashTableProtocol`` tables, but the header has no `version` field and
/// the values are offsets from start of the table.
///
/// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L173-L185
public protocol OldObjCStringHashTableProtocol: ObjCStringHashTableProtocol {
    /// Version of `objc_opt_t` to which the table belongs
    var optimizationVersion: Int { get }
}

extension ObjCStringHashTableProtocol where Self: LayoutWrapper, Layout == objc_stringhash_t {
    public var capacity: Int {
        numericCast(layout.capacity)
    }

    public var occupied: Int {
        numericCast(layout.occupied)
    }
}

extension OldObjCStringHashTableProtocol where Self: LayoutWrapper, Layout == objc_stringhash_t {
    internal var _geometry: _ObjCStringHashTableGeometry {
        .init(
            capacity: capacity,
            shift: layout.shift,
            mask: layout.mask,
            salt: layout.salt,
            scramble: withUnsafeBytes(of: layout.scramble) {
                Array($0.bindMemory(to: UInt32.self))
            },
            tabOffset: layoutSize,
            // version 12 points empty buckets to `zero` (renamed to `unused1` later)
            emptyStringOffset: optimizationVersion == 12 ? layoutOffset(of: \.unused1) : 0
        )
    }
}

/// Tables created from a field of `objc_opt_t`
internal protocol _OldObjCStringHashTable: OldObjCStringHashTableProtocol, LayoutWrapper
where Layout == objc_stringhash_t {
    init(layout: Layout, offset: Int, optimizationVersion: Int)
}
