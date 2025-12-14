//
//  PrebuiltLoader_Pre1165_3.swift
//  MachOKit
//
//  Created by p-x9 on 2024/11/09
//  
//

public struct PrebuiltLoader_Pre1165_3: LayoutWrapper, PrebuiltLoaderProtocol {
    public typealias Layout = prebuilt_loader_pre1165_3

    public var layout: Layout
    public var address: Int
}

extension PrebuiltLoader_Pre1165_3 {
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

    public var sectionLocations: SectionLocations {
        .init(layout: layout.sectionLocations)
    }
}

extension PrebuiltLoader_Pre1165_3 {
    public func path(in cache: DyldCache) -> String? {
        _path(in: cache)
    }

    public func altPath(in cache: DyldCache) -> String? {
        _altPath(in: cache)
    }

    public func dependentLoaderRefs(in cache: DyldCache) -> DataSequence<LoaderRef>? {
        _dependentLoaderRefs(in: cache)
    }

    public func objcBinaryInfo(in cache: DyldCache) -> ObjCBinaryInfo? {
        _objcBinaryInfo(in: cache)
    }
}

extension PrebuiltLoader_Pre1165_3 {
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

    public func objcBinaryInfo(in cache: DyldCacheLoaded) -> ObjCBinaryInfo? {
        // swiftlint:disable:previous unused_parameter
        guard layout.objcBinaryInfoOffset != 0,
              let baseAddress = UnsafeRawPointer(bitPattern: address) else {
            return nil
        }
        return baseAddress
            .advanced(by: numericCast(layout.objcBinaryInfoOffset))
            .assumingMemoryBound(to: ObjCBinaryInfo.self)
            .pointee
    }
}

extension PrebuiltLoader_Pre1165_3 {
    public func path(in cache: FullDyldCache) -> String? {
        _path(in: cache)
    }

    public func altPath(in cache: FullDyldCache) -> String? {
        _altPath(in: cache)
    }

    public func dependentLoaderRefs(in cache: FullDyldCache) -> DataSequence<LoaderRef>? {
        _dependentLoaderRefs(in: cache)
    }

    public func objcBinaryInfo(in cache: FullDyldCache) -> ObjCBinaryInfo? {
        _objcBinaryInfo(in: cache)
    }
}

extension PrebuiltLoader_Pre1165_3 {
    internal func _path<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> String? {
        guard let offset = cache.fileOffset(
            of: numericCast(address) + numericCast(layout.pathOffset)
        ) else { return nil }
        return cache.fileHandle.readString(offset: offset)
    }

    internal func _altPath<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> String? {
        guard layout.altPathOffset != 0 else { return nil }
        guard let offset = cache.fileOffset(
            of: numericCast(address) + numericCast(layout.altPathOffset)
        ) else { return nil }
        return cache.fileHandle.readString(offset: offset)
    }

    internal func _dependentLoaderRefs<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DataSequence<LoaderRef>? {
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

    internal func _objcBinaryInfo<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> ObjCBinaryInfo? {
        guard layout.objcBinaryInfoOffset != 0 else { return nil }
        guard let offset = cache.fileOffset(
            of: numericCast(address) + numericCast(layout.objcBinaryInfoOffset)
        ) else { return nil }
        return cache.fileHandle.read(offset: offset)
    }
}

extension PrebuiltLoader_Pre1165_3 {
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
