//
//  AotMetadataCommand.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/20
//
//

import Foundation

public struct AotMetadataCommand: LoadCommandWrapper {
    public typealias Layout = aot_metadata_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension AotMetadataCommand {
    public func imagePath(
        in machO: MachOFile
    ) -> String? {
        let linkeditOffset = linkeditOffset(in: machO)

        let offset = machO.headerStartOffset + linkeditOffset + Int(layout.x86_image_path_offset)
        return machO.fileHandle.readString(
            offset: numericCast(offset),
            size: Int(layout.x86_image_path_size)
        ) ?? ""
    }
}

extension AotMetadataCommand {
    public func codeFragment(
        in machO: MachOFile
    ) -> AotCodeFragment? {
        let linkeditOffset = linkeditOffset(in: machO)

        let offset = machO.headerStartOffset + linkeditOffset + Int(layout.fragment_offset)

        return .init(
            layout: try! machO.fileHandle.read(offset: offset),
            offset: offset
        )
    }
}

extension AotMetadataCommand {
    private func linkeditOffset(in machO: MachOFile) -> Int {
        let loadCommands = machO.loadCommands
        return if let linkedit = loadCommands.linkedit {
            linkedit.fileOffset
        } else if let linkedit = loadCommands.linkedit64 {
            linkedit.fileOffset
        } else { 0 }
    }
}
