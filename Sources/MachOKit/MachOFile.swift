//
//  MachOFile.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public class MachOFile {
    let url: URL
    let fileHandle: FileHandle

    public private(set) var isSwapped: Bool

    public let headerStartOffset: Int
    public let header: MachHeader

    public var is64bit: Bool { header.magic.is64BitMach }
    public var headerSize: Int {
        is64bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
    }

    public var cmdsStartOffset: Int {
        headerStartOffset + headerSize
    }

    public var loadCommands: LoadCommands {
        fileHandle.seek(toFileOffset: UInt64(cmdsStartOffset))
        let data = fileHandle.readData(ofLength: Int(header.sizeofcmds))

        return .init(
            data: data,
            numberOfCommands: Int(header.ncmds),
            isSwapped: isSwapped
        )
    }

    init(url: URL, headerStartOffset: Int = 0) throws {
        self.url = url
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle

        self.headerStartOffset = headerStartOffset
        fileHandle.seek(toFileOffset: UInt64(headerStartOffset))

        var header = fileHandle.readData(ofLength: MemoryLayout<MachHeader>.size).withUnsafeBytes {
            $0.load(as: MachHeader.self)
        }

        let isSwapped = header.magic.isSwapped
        if isSwapped {
            swap_mach_header(&header.layout, NXHostByteOrder())
        }

        self.isSwapped = isSwapped
        self.header = header
    }

    deinit {
        fileHandle.closeFile()
    }
}

extension MachOFile {
    public var strings: Strings? {
        if let symtab = loadCommands.symtab {
            fileHandle.seek(toFileOffset: UInt64(headerStartOffset) + UInt64(symtab.stroff))
            let data = fileHandle.readData(ofLength: Int(symtab.strsize))
            return Strings(
                data: data
            )
        }
        return nil
    }
}
