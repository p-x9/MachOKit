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

extension PrebuiltLoaderSet {
    public func loaders(in cache: DyldCache) -> [PrebuiltLoader]? {
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
            return cache.fileHandle.readData(
                offset: numericCast(offset),
                size: PrebuiltLoader.layoutSize
            ).withUnsafeBytes {
                let loader = $0.load(as: prebuilt_loader.self)
                return PrebuiltLoader(
                    layout: loader,
                    address: address + numericCast(_offset)
                )
            }
        }
    }

    public func loaders(in cache: DyldCacheLoaded) -> [PrebuiltLoader]? {
        // swiftlint:disable:previous unused_parameter
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
            let layout: prebuilt_loader = basePointer
                .advanced(by: numericCast(_offset))
                .assumingMemoryBound(to: prebuilt_loader.self).pointee
            return PrebuiltLoader(
                layout: layout,
                address: address + numericCast(_offset)
            )
        }
    }
}

extension PrebuiltLoaderSet {
    public func dyldCacheUUID(in cache: DyldCache) -> UUID? {
        guard layout.dyldCacheUUIDOffset != 0,
              let offset = cache.fileOffset(
            of: numericCast(address) + numericCast(layout.dyldCacheUUIDOffset)
        ) else {
            return nil
        }
        let data: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = cache.fileHandle.read(offset: offset)
        return .init(uuid: data)
    }

    public func mustBeMissingPaths(in cache: DyldCache) -> [String]? {
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
