//
//  OldObjCClassHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/21
//  
//

import Foundation
import MachOKitC

/// Precomputed class table of `objc_opt_t` version 12 - 15. (`objc_clsopt_t`)
///
/// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L391
public struct OldObjCClassHashTable: LayoutWrapper, OldObjCObjectHashTableProtocol {
    public typealias Layout = objc_stringhash_t

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
    public let optimizationVersion: Int
}

extension OldObjCClassHashTable: _OldObjCStringHashTable {}
