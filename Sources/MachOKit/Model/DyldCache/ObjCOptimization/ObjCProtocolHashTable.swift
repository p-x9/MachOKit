//
//  ObjCProtocolHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/20
//
//

import Foundation
import MachOKitC

/// Precomputed protocol table.
///
/// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/OptimizerObjC.h#L622
public struct ObjCProtocolHashTable: LayoutWrapper, ObjCObjectHashTableProtocol {
    public typealias Layout = objc_string_hash_table

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
}
