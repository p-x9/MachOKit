//
//  FilesetEntryCommand.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/13
//  
//

public struct FilesetEntryCommand: LoadCommandWrapper {
    public typealias Layout = fileset_entry_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension FilesetEntryCommand {
    public var virtualMemoryAddress: Int {
        numericCast(layout.vmaddr)
    }

    public var fileOffset: Int {
        numericCast(layout.fileoff)
    }
}

extension FilesetEntryCommand {
    public func entryId(cmdsStart: UnsafeRawPointer) -> String {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: Int(layout.entry_id.offset))
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}

extension FilesetEntryCommand {
    public func entryId(in machO: MachOFile) -> String {
        let offset = machO.cmdsStartOffset + offset + Int(layout.entry_id.offset)
        return machO.fileHandle.readString(
            offset: numericCast(offset),
            size: Int(layout.cmdsize) - layoutSize
        ) ?? ""
    }
}
