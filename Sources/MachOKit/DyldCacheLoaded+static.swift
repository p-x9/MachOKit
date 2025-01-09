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
        var size = 0
        guard let ptr = _dyld_get_shared_cache_range(&size),
              let cache = try? DyldCacheLoaded(ptr: ptr) else {
            return nil
        }
        return cache
    }
}
#endif
