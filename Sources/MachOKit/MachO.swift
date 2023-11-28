//
//  MachO.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public struct MachO {
    public let ptr: UnsafeRawPointer

    public let is64Bit: Bool
    public let loadCommands: LoadCommands

    public var symbols64: Symbols64? {
        guard is64Bit else {
            return nil
        }
        if let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64,
           let symtab = loadCommands.symtab {
            return Symbols64(ptr: ptr, text: text, linkedit: linkedit, symtab: symtab)
        }
        return nil
    }

    public var symbols32: Symbols? {
        guard !is64Bit else {
            return nil
        }
        if let text = loadCommands.text,
           let linkedit = loadCommands.linkedit,
           let symtab = loadCommands.symtab {
            return Symbols(ptr: ptr, text: text, linkedit: linkedit, symtab: symtab)
        }
        return nil
    }

    public init(ptr: UnsafePointer<mach_header>) {
        self.ptr = .init(ptr)

        let header = ptr.pointee

        self.is64Bit = header.magic == MH_MAGIC_64 || header.magic == MH_CIGAM_64
        let start = UnsafeRawPointer(ptr)
            .advanced(
                by: is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
            )
        loadCommands = .init(start: start, numberOfCommands: Int(header.ncmds))
    }
}
