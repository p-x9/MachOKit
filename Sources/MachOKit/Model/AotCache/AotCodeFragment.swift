//
//  AotCodeFragment.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/20
//  
//

import MachOKitC

public struct AotCodeFragment: LayoutWrapper {
    public typealias Layout = aot_code_fragment_metadata

    public var layout: Layout
    public let offset: Int
}

extension AotCodeFragment {
    public func instructionMap(
        in machO: MachOFile
    ) -> AotInstructionMap? {
        guard layout.instruction_map_size > 0 else { return nil }
        let offset = machO.headerStartOffset + linkeditOffset(in: machO) + numericCast(layout.instruction_map_offset)
        return .init(
            header: try! machO.fileHandle.read(offset: offset),
            offset: offset
        )
    }
}

extension AotCodeFragment {
    public func branchData(
        in machO: MachOFile
    ) -> AotBranchData? {
        guard layout.branch_data_size > 0 else { return nil }
        let offset = machO.headerStartOffset + linkeditOffset(in: machO) + numericCast(layout.branch_data_offset)
        return .init(
            header: try! machO.fileHandle.read(offset: offset),
            offset: offset
        )
    }
}

extension AotCodeFragment {
    private func linkeditOffset(in machO: MachOFile) -> Int {
        let loadCommands = machO.loadCommands
        return if let linkedit = loadCommands.linkedit {
            linkedit.fileOffset
        } else if let linkedit = loadCommands.linkedit64 {
            linkedit.fileOffset
        } else { 0 }
    }
}
