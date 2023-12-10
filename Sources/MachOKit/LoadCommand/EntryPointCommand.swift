//
//  EntryPointCommand.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public struct EntryPointCommand: LoadCommandWrapper {
    public typealias Layout = entry_point_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension EntryPointCommand {
    public func mainStartPointer(machOStart: UnsafeRawPointer) -> UnsafeRawPointer {
        machOStart
            .advanced(by: numericCast(layout.entryoff))
    }
}
