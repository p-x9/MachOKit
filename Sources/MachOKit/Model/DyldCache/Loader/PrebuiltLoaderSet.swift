//
//  PrebuiltLoaderSet.swift
//
//
//  Created by p-x9 on 2024/07/09
//
//

import Foundation

public struct PrebuiltLoaderSet: LayoutWrapper {
    public typealias Layout = prebuilt_loader_set

    public var layout: Layout
    public var address: Int
}

// TODO: ObjC Flags (from dyld-1284.13)
// https://github.com/apple-oss-distributions/dyld/blob/031f1c6ffb240a094f3f2f85f20dfd9e3f15b664/dyld/PrebuiltLoader.h#L338

extension PrebuiltLoaderSet {
    public func loaders(in cache: DyldCache) -> [PrebuiltLoader]? {
        _loaders(in: cache)
    }

    public func loaders(in cache: DyldCacheLoaded) -> [PrebuiltLoader]? {
        // swiftlint:disable:previous unused_parameter
        if let version, version.isPre1165_3 {
            return nil
        }

        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        let offsets: MemorySequence<UInt32> = .init(
            basePointer: basePointer
                .advanced(by: numericCast(layout.loadersArrayOffset))
                .assumingMemoryBound(to: UInt32.self),
            numberOfElements: numericCast(layout.loadersArrayCount)
        )
        return offsets.compactMap { _offset -> PrebuiltLoader? in
            let layout: PrebuiltLoader.Layout = basePointer
                .advanced(by: numericCast(_offset))
                .autoBoundPointee()
            return .init(
                layout: layout,
                address: address + numericCast(_offset)
            )
        }
    }

    public func loaders(in cache: FullDyldCache) -> [PrebuiltLoader]? {
        _loaders(in: cache)
    }
}

extension PrebuiltLoaderSet {
    public func loaders_pre1165_3(in cache: DyldCache) -> [PrebuiltLoader_Pre1165_3]? {
        _loaders_pre1165_3(in: cache)
    }

    public func loaders_pre1165_3(in cache: DyldCacheLoaded) -> [PrebuiltLoader_Pre1165_3]? {
        // swiftlint:disable:previous unused_parameter
        guard let version, version.isPre1165_3 else { return nil }

        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        let offsets: MemorySequence<UInt32> = .init(
            basePointer: basePointer
                .advanced(by: numericCast(layout.loadersArrayOffset))
                .assumingMemoryBound(to: UInt32.self),
            numberOfElements: numericCast(layout.loadersArrayCount)
        )
        return offsets.compactMap { _offset -> PrebuiltLoader_Pre1165_3? in
            let layout: PrebuiltLoader_Pre1165_3.Layout = basePointer
                .advanced(by: numericCast(_offset))
                .autoBoundPointee()
            return .init(
                layout: layout,
                address: address + numericCast(_offset)
            )
        }
    }

    public func loaders_pre1165_3(in cache: FullDyldCache) -> [PrebuiltLoader_Pre1165_3]? {
        _loaders_pre1165_3(in: cache)
    }
}

extension PrebuiltLoaderSet {
    public func dyldCacheUUID(in cache: DyldCache) -> UUID? {
        _dyldCacheUUID(in: cache)
    }

    public func mustBeMissingPaths(in cache: DyldCache) -> [String]? {
        _mustBeMissingPaths(in: cache)
    }
}

extension PrebuiltLoaderSet {
    public func dyldCacheUUID(in cache: DyldCacheLoaded) -> UUID? {
        // swiftlint:disable:previous unused_parameter
        guard layout.dyldCacheUUIDOffset != 0 else { return nil }
        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }

        let data: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = basePointer
            .advanced(by: numericCast(layout.dyldCacheUUIDOffset))
            .autoBoundPointee()
        return .init(uuid: data)
    }

    public func mustBeMissingPaths(in cache: DyldCacheLoaded) -> [String]? {
        // swiftlint:disable:previous unused_parameter
        guard layout.mustBeMissingPathsOffset != 0,
              layout.mustBeMissingPathsCount != 0 else {
            return nil
        }
        guard let basePointer = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        var offset: Int = numericCast(layout.mustBeMissingPathsOffset)
        var strings: [String] = []
        for _ in 0 ..< layout.mustBeMissingPathsCount {
            guard let string = String(
                cString: basePointer
                    .advanced(by: offset)
                    .assumingMemoryBound(to: CChar.self),
                encoding: .utf8
            ) else {
                break
            }
            strings.append(string)
            offset += numericCast(string.utf8.count) + 1 // \0
        }
        return strings
    }
}

extension PrebuiltLoaderSet {
    public func dyldCacheUUID(in cache: FullDyldCache) -> UUID? {
        _dyldCacheUUID(in: cache)
    }

    public func mustBeMissingPaths(in cache: FullDyldCache) -> [String]? {
        _mustBeMissingPaths(in: cache)
    }
}

extension PrebuiltLoaderSet {
    // [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/dyld/PrebuiltLoader.h#L326)
    public var magic: String? {
        withUnsafeBytes(of: layout.magic.bigEndian, {
            let cString = $0.map({ CChar($0)} ) + [0]
            return String(
                cString: cString,
                encoding: .utf8
            )
        })
    }
}

extension PrebuiltLoaderSet {
    public enum KnownVersion: UInt32, CaseIterable {
        /// from dyld-940
        case v0x041c09d6 = 0x041c09d6
        /// from dyld-955
        case v0xcb8ba960 = 0xcb8ba960
        /// from dyld-1042.1
        case v0x4d2b8647 = 0x4d2b8647
        /// from dyld-1122.1
        case v0xd647423f = 0xd647423f
        /// from dyld-1160.6
        case v0x9a661060 = 0x9a661060
        /// from dyld-1231.3
        case v0x173a676e = 0x173a676e
        /// from dyld-1241.17
        case v0x18cf6421 = 0x18cf6421

        public var isLatest: Bool {
            self == .v0x18cf6421
        }

        public var isPre1165_3: Bool {
            [
                .v0x041c09d6,
                .v0xcb8ba960,
                .v0x4d2b8647,
                .v0xd647423f,
                .v0x9a661060
            ].contains(self)
        }
    }

    public var version: KnownVersion? {
        KnownVersion(rawValue: layout.versionHash)
    }

    public var isKnownVersion: Bool {
        version != nil
    }

    public var isLatestVersion: Bool {
        version?.isLatest ?? false
    }
}

extension PrebuiltLoaderSet {
    internal func _loaders<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> [PrebuiltLoader]? {
        if let version, version.isPre1165_3 {
            return nil
        }

        guard let offset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        let offsets: DataSequence<UInt32> = cache.fileHandle.readDataSequence(
            offset: offset + numericCast(layout.loadersArrayOffset),
            numberOfElements: numericCast(layout.loadersArrayCount)
        )
        return offsets.compactMap { _offset -> PrebuiltLoader? in
            guard let offset = cache.fileOffset(
                of: numericCast(address) + numericCast(_offset)
            ) else {
                return nil
            }
            return try! cache.fileHandle.readData(
                offset: numericCast(offset),
                length: PrebuiltLoader.layoutSize
            ).withUnsafeBytes {
                let loader = $0.load(as: PrebuiltLoader.Layout.self)
                return .init(
                    layout: loader,
                    address: address + numericCast(_offset)
                )
            }
        }
    }

    internal func _loaders_pre1165_3<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> [PrebuiltLoader_Pre1165_3]? {
        guard let version, version.isPre1165_3 else { return nil }

        guard let offset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        let offsets: DataSequence<UInt32> = cache.fileHandle.readDataSequence(
            offset: offset + numericCast(layout.loadersArrayOffset),
            numberOfElements: numericCast(layout.loadersArrayCount)
        )
        return offsets.compactMap { _offset -> PrebuiltLoader_Pre1165_3? in
            guard let offset = cache.fileOffset(
                of: numericCast(address) + numericCast(_offset)
            ) else {
                return nil
            }
            return try! cache.fileHandle.readData(
                offset: numericCast(offset),
                length: PrebuiltLoader_Pre1165_3.layoutSize
            ).withUnsafeBytes {
                let loader = $0.load(as: PrebuiltLoader_Pre1165_3.Layout.self)
                return .init(
                    layout: loader,
                    address: address + numericCast(_offset)
                )
            }
        }
    }

    internal func _dyldCacheUUID<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> UUID? {
        guard layout.dyldCacheUUIDOffset != 0,
              let offset = cache.fileOffset(
                of: numericCast(address) + numericCast(layout.dyldCacheUUIDOffset)
              ) else {
            return nil
        }
        let data: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = cache.fileHandle.read(offset: offset)
        return .init(uuid: data)
    }

    internal func _mustBeMissingPaths<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> [String]? {
        guard layout.mustBeMissingPathsOffset != 0,
              layout.mustBeMissingPathsCount != 0 else {
            return nil
        }
        guard layout.mustBeMissingPathsOffset != 0,
              var offset = cache.fileOffset(
                of: numericCast(address) + numericCast(layout.mustBeMissingPathsOffset)
              ) else {
            return nil
        }
        var strings: [String] = []
        for _ in 0 ..< layout.mustBeMissingPathsCount {
            guard let string = cache.fileHandle.readString(offset: offset) else {
                break
            }
            strings.append(string)
            offset += UInt64(string.utf8.count) + 1 // \0
        }
        return strings
    }
}
