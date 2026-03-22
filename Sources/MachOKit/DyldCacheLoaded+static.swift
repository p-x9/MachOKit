//
//  DyldCacheLoaded+static.swift
//  MachOKit
//
//  Created by p-x9 on 2025/01/09
//  
//

#if canImport(Darwin)
extension DyldCacheLoaded {
    public static var current: DyldCacheLoaded? {
        guard let range = _MachOKitDyldRuntime.sharedCacheRange(),
              range.size > 0,
              let cache = try? DyldCacheLoaded(ptr: range.ptr) else {
            return nil
        }
        return cache
    }
}
#endif
