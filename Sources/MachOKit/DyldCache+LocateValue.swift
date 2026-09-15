//
//  DyldCache+LocateValue.swift
//
//
//  Created by p-x9 on 2026/06/24
//
//

import Foundation

extension DyldCache {
    /// A pair of a ``DyldCache`` and a value resolved from that cache.
    ///
    /// Returned by ``locateValue(_:)-(KeyPath<DyldCache,_>)`` and
    /// ``locateValue(_:)-((DyldCache)->_)``.
    /// The `cache` field identifies which cache in the hierarchy actually
    /// produced `value`, which is necessary when interpreting offsets or
    /// addresses contained in `value`.
    @_spi(Support)
    public struct LocatedValue<Value> {
        /// The cache that produced ``value``.
        ///
        /// May be the receiver, its ``DyldCache/mainCache``, or one of the
        /// main cache's subcaches.
        public let cache: DyldCache
        /// The resolved value.
        public let value: Value

        public init(cache: DyldCache, value: Value) {
            self.cache = cache
            self.value = value
        }
    }
}

extension DyldCache {
    /// Locate the first non-`nil` value of an optional key path across this
    /// cache hierarchy.
    ///
    /// Resolution order:
    /// 1. The receiver.
    /// 2. The receiver's ``mainCache`` (skipped if it is the receiver).
    /// 3. Each subcache of the main cache, in subcache-array order.
    ///
    /// Caches are deduplicated by ``DyldCacheHeader/uuid`` so the same cache
    /// is not evaluated twice when the receiver is itself the main cache or
    /// one of its subcaches.
    ///
    /// - Parameter keyPath: A key path returning an optional value.
    /// - Returns: A ``LocatedValue`` describing where the value was resolved,
    ///   or `nil` if no cache in the hierarchy produced a value.
    @_spi(Support)
    @inline(__always)
    public func locateValue<Value>(
        _ keyPath: KeyPath<DyldCache, Value?>
    ) -> LocatedValue<Value>? {
        locateValue { $0[keyPath: keyPath] }
    }

    /// Locate the first non-`nil` value produced by `resolver` across this
    /// cache hierarchy.
    ///
    /// Resolution order matches ``locateValue(_:)-(KeyPath<DyldCache,_>)``.
    ///
    /// Use this overload when the lookup needs computation or `throws` access
    /// (for example ``DyldCache/symbolCache``).
    ///
    /// - Parameter resolver: A closure returning an optional value for a
    ///   given cache.
    /// - Returns: A ``LocatedValue`` describing where the value was resolved,
    ///   or `nil` if no cache in the hierarchy produced a value.
    /// - Note: Opening subcaches may incur file I/O. Callers that look up
    ///   values repeatedly should cache the resulting ``LocatedValue``.
    @_spi(Support)
    public func locateValue<Value>(
        _ resolver: (DyldCache) throws -> Value?
    ) rethrows -> LocatedValue<Value>? {
        var visited: Set<UUID> = []

        if let located = try _resolve(self, with: resolver, visited: &visited) {
            return located
        }

        guard let mainCache else { return nil }
        if let located = try _resolve(mainCache, with: resolver, visited: &visited) {
            return located
        }

        guard let subCaches = mainCache.subCaches else { return nil }
        for entry in subCaches {
            guard let subCache = try? entry.subcache(for: mainCache) else {
                continue
            }
            if let located = try _resolve(subCache, with: resolver, visited: &visited) {
                return located
            }
        }
        return nil
    }

    @inline(__always)
    private func _resolve<Value>(
        _ cache: DyldCache,
        with resolver: (DyldCache) throws -> Value?,
        visited: inout Set<UUID>
    ) rethrows -> LocatedValue<Value>? {
        let uuid = cache.header.uuid
        guard visited.insert(uuid).inserted else { return nil }
        guard let value = try resolver(cache) else { return nil }
        return .init(cache: cache, value: value)
    }
}
