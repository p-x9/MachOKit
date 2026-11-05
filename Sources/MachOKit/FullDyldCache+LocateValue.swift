//
//  FullDyldCache+LocateValue.swift
//  MachOKit
//

import Foundation

extension FullDyldCache {
    /// Locate the first non-`nil` value in the main cache and its subcaches.
    @_spi(Support)
    @inline(__always)
    public func locateValue<Value>(
        _ keyPath: KeyPath<DyldCache, Value?>
    ) -> DyldCache.LocatedValue<Value>? {
        locateValue { $0[keyPath: keyPath] }
    }

    /// Locate a value using the main cache followed by its preopened subcaches.
    ///
    /// The excluded cache is treated as already visited. Caches with duplicate
    /// UUIDs are evaluated only once, matching `DyldCache.locateValue`.
    /// Only errors thrown by `resolver` are propagated; no files are opened.
    @_spi(Support)
    public func locateValue<Value>(
        _ resolver: (DyldCache) throws -> Value?,
        excluding excludedCache: DyldCache? = nil
    ) rethrows -> DyldCache.LocatedValue<Value>? {
        var visited: Set<UUID> = []
        if let excludedCache { visited.insert(excludedCache.header.uuid) }

        let mainCache = self.mainCache
        if visited.insert(mainCache.header.uuid).inserted,
           let value = try resolver(mainCache) {
            return .init(cache: mainCache, value: value)
        }

        for cache in subCaches {
            guard visited.insert(cache.header.uuid).inserted else { continue }
            if let value = try resolver(cache) {
                return .init(cache: cache, value: value)
            }
        }
        return nil
    }
}
