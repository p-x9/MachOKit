//
//  FatFile.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public class FatFile {
    let url: URL
    let fileHandle: FileHandle

    public private(set) var isSwapped: Bool
    public let header: FatHeader

    public var is64bit: Bool { header.magic.is64BitFat }
    public var headerSize: Int {
        MemoryLayout<fat_header>.size
    }
    public var archesSize: Int {
        Int(header.nfat_arch) * (is64bit ? MemoryLayout<fat_arch_64>.size : MemoryLayout<fat_arch>.size)
    }

    public var archesStartOffset: Int {
        headerSize
    }

    public var arches: [FatArch] {
        let data = fileHandle.readData(
            offset: UInt64(archesStartOffset),
            size: archesSize
        )
        return header.arches(data: data, isSwapped: isSwapped)
    }

    init(url: URL) throws {
        self.url = url
        self.fileHandle = try FileHandle(forReadingFrom: url)

        var header: FatHeader = fileHandle.read(
            offset: 0
        )

        let isSwapped = header.magic.isSwapped
        if isSwapped {
            swap_fat_header(&header.layout, NXHostByteOrder())
        }

        self.isSwapped = isSwapped
        self.header = header
    }

    deinit {
        fileHandle.closeFile()
    }
}

extension FatFile {
    public func machOFiles() throws -> [MachOFile] {
        try arches.map {
            try .init(url: url, headerStartOffset: Int($0.offset))
        }
    }
}
