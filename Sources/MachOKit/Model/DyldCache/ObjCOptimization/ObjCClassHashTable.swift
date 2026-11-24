//
//  ObjCClassHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/20
//
//

import Foundation
import MachOKitC

/// Precomputed class table.
///
/// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/OptimizerObjC.h#L577
public struct ObjCClassHashTable: LayoutWrapper, ObjCObjectHashTableProtocol {
    public typealias Layout = objc_string_hash_table

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
}

extension ObjCClassHashTable {
    /// `occupied + duplicateCount`, same as `ClassHashTable::classCount()` in dyld
    ///
    /// A bucket that has duplicates is counted in both `occupied` and `duplicateCount`,
    /// so this can be larger than the total number of ``ObjCObjectHashTableEntry/objects``.
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: number of classes
    public func classCount(in cache: DyldCache) -> Int? {
        guard let duplicateCount = duplicateCount(in: cache) else {
            return nil
        }
        return occupied + duplicateCount
    }

    /// `occupied + duplicateCount`, same as `ClassHashTable::classCount()` in dyld
    ///
    /// A bucket that has duplicates is counted in both `occupied` and `duplicateCount`,
    /// so this can be larger than the total number of ``ObjCObjectHashTableEntry/objects``.
    /// - Parameter cache: FullDyldCache to which `self` belongs
    /// - Returns: number of classes
    public func classCount(in cache: FullDyldCache) -> Int? {
        guard let duplicateCount = duplicateCount(in: cache) else {
            return nil
        }
        return occupied + duplicateCount
    }

    /// `occupied + duplicateCount`, same as `ClassHashTable::classCount()` in dyld
    ///
    /// A bucket that has duplicates is counted in both `occupied` and `duplicateCount`,
    /// so this can be larger than the total number of ``ObjCObjectHashTableEntry/objects``.
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: number of classes
    public func classCount(in cache: DyldCacheLoaded) -> Int {
        occupied + duplicateCount(in: cache)
    }
}
