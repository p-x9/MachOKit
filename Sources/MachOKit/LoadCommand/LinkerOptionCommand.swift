//
//  LinkerOptionCommand.swift
//
//
//  Created by p-x9 on 2023/12/18.
//  
//

import Foundation

public struct LinkerOptionCommand: LoadCommandWrapper {
    public typealias Layout = linker_option_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension LinkerOptionCommand {
    public func options(cmdsStart: UnsafeRawPointer) -> [String] {
        // swiftlint:disable:next empty_count
        guard layout.count > 0 else { return [] }

        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .assumingMemoryBound(to: UInt8.self)
        let strings = MachOImage.Strings(
            basePointer: ptr,
            tableSize: Int(layout.cmdsize) - layoutSize
        ).map(\.string)

        return Array(strings[0..<Int(layout.count)])
    }

    public func options(in machO: MachOFile) -> [String] {
        // swiftlint:disable:next empty_count
        guard layout.count > 0 else { return [] }

        let offset = machO.cmdsStartOffset + offset + layoutSize
        let size = Int(layout.cmdsize) - layoutSize

        let strings = MachOFile.Strings(
            machO: machO,
            offset: offset,
            size: size
        ).map(\.string)

        return Array(strings[0..<Int(layout.count)])
    }
}
