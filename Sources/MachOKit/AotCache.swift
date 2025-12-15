//
//  AotCache.swift
//  MachOKit
//
//  Created by p-x9 on 2025/01/29
//  
//

import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
#else
@_implementationOnly import FileIO
#endif

public struct AotCache {
    typealias File = MemoryMappedFile

    /// URL of loaded dyld cache file
    public let url: URL
    let fileHandle: File

//    public var headerSize: Int {
//        header.headerSize
//    }

    /// Header for dyld cache
    public let header: AotCacheHeader

    public init(url: URL) throws {
        self.url = url
        let fileHandle = try File.open(
            url: url,
            isWritable: false
        )
        self.fileHandle = fileHandle

        // read header
        self.header = try! fileHandle.read(
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
        .init(
            fileSice: try! fileHandle.fileSlice(
                offset: numericCast(header.code_signature_offset),
                length: numericCast(header.code_signature_size)
            )
        )
    }
}

extension AotCache {
    /// Sequence of mapping infos
    public var mappingInfos: DataSequence<DyldCacheMappingInfo> {
        fileHandle.readDataSequence(
            offset: numericCast(header.layoutSize),
            numberOfElements: 3
        )
    }
}

extension AotCache {
    /// Sequence of code fragments
    public var codeFragments: CodeFragments {
        let mapping = mappingInfos[0]

        let offset = header.headerSize
        let size = numericCast(mapping.size) - offset

        let fileSlice = try! fileHandle.fileSlice(
            offset: offset,
            length: numericCast(mapping.size) - offset
        )
        return .init(
            fileSlice: fileSlice,
            offset: offset,
            size: size,
            numberOfEntries: numericCast(header.num_code_fragments)
        )
    }
}
