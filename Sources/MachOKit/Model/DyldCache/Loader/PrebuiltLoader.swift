//
//  PrebuiltLoader.swift
//  
//
//  Created by p-x9 on 2024/07/09
//  
//

import Foundation

public struct PrebuiltLoader: LayoutWrapper, PrebuiltLoaderProtocol {
    public typealias Layout = prebuilt_loader

    public var layout: Layout
    public var address: Int
}

extension PrebuiltLoader {
    // always true
    public var isPrebuilt: Bool {
        layout.loader.isPrebuilt != 0
    }

    public var neverUnload: Bool {
        layout.loader.neverUnload != 0
    }

    public var isPremapped: Bool {
        layout.loader.isPremapped != 0
    }

    public var ref: LoaderRef {
        .init(layout: layout.loader.ref)
    }

    public var uuid: UUID {
        .init(uuid: layout.loader.uuid)
    }

    public var sectionLocations: SectionLocations {
        .init(layout: layout.sectionLocations)
    }
}

extension PrebuiltLoader {
    public func path(in cache: DyldCache) -> String? {
        guard let offset = cache.fileOffset(
            of: numericCast(address) + numericCast(layout.pathOffset)
        ) else { return nil }
        return cache.fileHandle.readString(offset: offset)
    }

    public func altPath(in cache: DyldCache) -> String? {
        guard layout.altPathOffset != 0 else { return nil }
        guard let offset = cache.fileOffset(
            of: numericCast(address) + numericCast(layout.altPathOffset)
        ) else { return nil }
        return cache.fileHandle.readString(offset: offset)
    }

    public func dependentLoaderRefs(in cache: DyldCache) -> DataSequence<LoaderRef>? {
        guard layout.dependentLoaderRefsArrayOffset != 0,
              let offset = cache.fileOffset(
                of: numericCast(address) + numericCast(layout.dependentLoaderRefsArrayOffset)
              ) else {
            return nil
        }
        return cache.fileHandle.readDataSequence(
            offset: offset,
            numberOfElements: numericCast(layout.depCount)
        )
    }
}

extension PrebuiltLoader {
    public func path(in cache: DyldCacheLoaded) -> String? {
        // swiftlint:disable:previous unused_parameter
        guard let baseAddress = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        return String(
            cString: baseAddress
                .advanced(by: numericCast(layout.pathOffset))
                .assumingMemoryBound(to: CChar.self)
        )
    }

    public func altPath(in cache: DyldCacheLoaded) -> String? {
        // swiftlint:disable:previous unused_parameter
        guard layout.altPathOffset != 0 else { return nil }
        guard let baseAddress = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        return String(
            cString: baseAddress
                .advanced(by: numericCast(layout.altPathOffset))
                .assumingMemoryBound(to: CChar.self)
        )
    }

    public func dependentLoaderRefs(in cache: DyldCacheLoaded) -> MemorySequence<LoaderRef>? {
        // swiftlint:disable:previous unused_parameter
        guard layout.dependentLoaderRefsArrayOffset != 0,
              let baseAddress = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        return .init(
            basePointer: baseAddress
                .advanced(by: numericCast(layout.dependentLoaderRefsArrayOffset))
                .assumingMemoryBound(to: LoaderRef.self),
            numberOfElements: numericCast(layout.depCount)
        )
    }
}

extension PrebuiltLoader {
    // [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/dyld/Loader.h#L317)
    public var magic: String? {
        withUnsafeBytes(of: layout.loader.magic.bigEndian, {
            let cString = $0.map({ CChar($0)} ) + [0]
            return String(
                cString: cString,
                encoding: .utf8
            )
        })
    }
}
