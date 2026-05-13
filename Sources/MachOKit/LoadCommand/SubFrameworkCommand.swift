//
//  SubFrameworkCommand.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/13
//  
//

public struct SubFrameworkCommand: LoadCommandWrapper {
    public typealias Layout = sub_framework_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension SubFrameworkCommand {
    public func umbrella(cmdsStart: UnsafeRawPointer) -> String {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: Int(layout.umbrella.offset))
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}

extension SubFrameworkCommand {
    public func umbrella(in machO: MachOFile) -> String {
        let offset = machO.cmdsStartOffset + offset + Int(layout.umbrella.offset)
        return machO.fileHandle.readString(
            offset: numericCast(offset),
            size: Int(layout.cmdsize) - layoutSize
        ) ?? ""
    }
}
