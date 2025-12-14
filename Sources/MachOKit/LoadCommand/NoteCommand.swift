//
//  NoteCommand.swift
//  MachOKit
//
//  Created by p-x9 on 2024/12/11
//  
//

import Foundation

public struct NoteCommand: LoadCommandWrapper {
    public typealias Layout = note_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension NoteCommand {
    public var dataOwner: String {
        .init(tuple: layout.data_owner)
    }

    public func data(in machO: MachOFile) -> Data {
        try! machO.fileHandle.readData(
            offset: machO.headerStartOffset + numericCast(layout.offset),
            length: numericCast(layout.size)
        )
    }

    public func data(in machO: MachOImage) -> Data {
        .init(
            bytes: machO.ptr
                .advanced(by: numericCast(layout.offset)),
            count: numericCast(layout.size)
        )
    }
}
