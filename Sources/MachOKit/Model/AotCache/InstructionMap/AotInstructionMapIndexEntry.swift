//
//  AotInstructionMapIndexEntry.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/16
//  
//

import MachOKitC

public struct AotInstructionMapIndexEntry: LayoutWrapper, Sendable {
    public typealias Layout = aot_instruction_map_index_entry

    public var layout: Layout
}

extension AotInstructionMapIndexEntry: Equatable {
    public static func == (
        lhs: AotInstructionMapIndexEntry,
        rhs: AotInstructionMapIndexEntry
    ) -> Bool {
        lhs.layout.x86_code_offset == rhs.layout.x86_code_offset
        && lhs.layout.arm_code_offset == rhs.layout.arm_code_offset
        && lhs.layout.submap_offset == rhs.layout.submap_offset
        && lhs.layout.submap_delta_count == rhs.layout.submap_delta_count
    }
}

extension AotInstructionMapIndexEntry {
    public var x86CodeOffset: Int {
        numericCast(layout.x86_code_offset)
    }

    public var armCodeOffset: Int {
        numericCast(layout.arm_code_offset)
    }

    public var submapOffset: Int {
        numericCast(layout.submap_offset)
    }

    public var submapDeltaCount: Int {
        numericCast(layout.submap_delta_count)
    }

    public var submapRecordCount: Int {
        submapDeltaCount
    }
}
