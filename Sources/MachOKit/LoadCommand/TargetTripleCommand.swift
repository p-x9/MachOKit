//
//  TargetTripleCommand.swift
//  MachOKit
//
//  Created by p-x9 on 2025/02/22
//  
//

import Foundation

public struct TargetTripleCommand: LoadCommandWrapper {
    public typealias Layout = target_triple_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension TargetTripleCommand {
    public func triple(cmdsStart: UnsafeRawPointer) -> String {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: Int(layout.triple.offset))
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}

extension TargetTripleCommand {
    public func path(in machO: MachOFile) -> String {
        let offset = machO.cmdsStartOffset + offset + Int(layout.triple.offset)
        return machO.fileHandle.readString(
            offset: numericCast(offset),
            size: Int(layout.cmdsize) - layoutSize
        ) ?? ""
    }
}
