//
//  OldObjCProtocolHashTable2.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/21
//  
//

import Foundation
import MachOKitC

/// Precomputed protocol table that tracks header infos. (`objc_protocolopt2_t`)
///
/// Added in the middle of `objc_opt_t` version 15 (dyld-732 / objc4-779) so that the runtime can
/// pick a protocol in a loaded image (`sharedCacheSupportsProtocolRoots`).
/// It has the same layout as `objc_clsopt_t`.
///
/// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L698
/// https://github.com/apple-oss-distributions/dyld/blob/84bd745c32faa3a7cb1b15d1516aa695377841df/dyld3/shared-cache/OptimizerObjC.cpp#L902
/// https://github.com/apple-oss-distributions/objc4/blob/d94c489e58e1f8c9c4d2e56693a4699b27fec05d/runtime/objc-opt.mm#L208-L229
public struct OldObjCProtocolHashTable2: LayoutWrapper, OldObjCObjectHashTableProtocol {
    public typealias Layout = objc_stringhash_t

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
    public let optimizationVersion: Int
}

extension OldObjCProtocolHashTable2: _OldObjCStringHashTable {}
