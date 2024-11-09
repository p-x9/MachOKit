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

    public var ref: LoaderRef {
        .init(layout: layout.loader.ref)
    }
}

extension PrebuiltLoader_Pre1165_3 {
    public func path(in cache: DyldCache) -> String? {
        guard let offset = cache.fileOffset(
            of: numericCast(address) + numericCast(layout.pathOffset)
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
