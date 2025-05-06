//
//  AotCache.swift
//  MachOKit
//
//  Created by p-x9 on 2025/01/29
//  
//

import Foundation

public struct AotCache {
    /// URL of loaded dyld cache file
    public let url: URL
    let fileHandle: FileHandle

//    public var headerSize: Int {
//        header.headerSize
//    }

    /// Header for dyld cache
    public let header: AotCacheHeader

    public init(url: URL) throws {
        self.url = url
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle

        // read header
        self.header = fileHandle.read(
            offset: 0
        )

        // check magic of header
        guard header.magic == "AotCache" else {
            throw MachOKitError.invalidMagic
        }
    }
}

extension AotCache {
    public var codeSign: MachOFile.CodeSign? {
        let data = fileHandle.readData(
            offset: numericCast(header.code_signature_offset),
            size: numericCast(header.code_signature_size)
        )
        return .init(data: data)
    }
}

extension AotCache {
    /// Sequence of mapping infos
    public var mappingInfos: DataSequence<DyldCacheMappingInfo>? {
        fileHandle.readDataSequence(
            offset: numericCast(header.layoutSize),
            numberOfElements: 3
        )
    }
}
