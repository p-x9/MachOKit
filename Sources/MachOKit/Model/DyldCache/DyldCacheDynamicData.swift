//
//  DyldCacheDynamicData.swift
//  MachOKit
//
//  Created by p-x9 on 2025/02/28
//  
//

import Foundation

public struct DyldCacheDynamicData: LayoutWrapper {
    public typealias Layout = dyld_cache_dynamic_data_header

    public var layout: Layout
}

extension DyldCacheDynamicData {
    public var magic: String {
        .init(tuple: layout.magic)
    }
}

#if canImport(Darwin)
extension DyldCacheDynamicData {
    public var path: String {
        let path: UnsafeMutablePointer<CChar> = .allocate(capacity: Int(MAXPATHLEN))
        var fsid: UInt64 = numericCast(layout.fsId)
        return withUnsafeMutablePointer(to: &fsid) { fsid in
            fsgetpath(
                path,
                Int(MAXPATHLEN),
                UnsafeMutableRawPointer(fsid).assumingMemoryBound(to: fsid_t.self),
                layout.fsObjId
            )
            return String(cString: path)
        }
    }
}
#endif
