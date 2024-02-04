//
//  DylinkerCommand.swift
//
//
//  Created by p-x9 on 2023/12/02.
//  
//

import Foundation

public struct DylinkerCommand: LoadCommandWrapper {
    public typealias Layout = dylinker_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension DylinkerCommand {
    public func name(cmdsStart: UnsafeRawPointer) -> String {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: Int(layout.name.offset))
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}

extension DylinkerCommand {
    public func name(in machO: MachOFile) -> String {
        let offset = machO.cmdsStartOffset + offset + Int(layout.name.offset)
        return machO.fileHandle.readString(
            offset: numericCast(offset),
            size: Int(layout.cmdsize) - layoutSize
        ) ?? ""
    }
}
