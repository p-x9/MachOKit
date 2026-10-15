//
//  AotInstructionMapHeader.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/16
//  
//

import MachOKitC

public struct AotInstructionMapHeader: LayoutWrapper, Sendable {
    public typealias Layout = aot_instruction_map_header

    public var layout: Layout
}

extension AotInstructionMapHeader {
    public var armInstructionByteSize: Int {
        numericCast(layout.arm_instruction_byte_size)
    }

    public var x86CodeDeltaRiceWidth: Int {
        numericCast(layout.x86_code_delta_rice_width)
    }

    public var armInstructionDeltaRiceWidth: Int {
        numericCast(layout.arm_instruction_delta_rice_width)
    }

    public var mapSize: Int {
        numericCast(layout.map_size)
    }

    public var entryCount: Int {
        numericCast(layout.entry_count)
    }

    public var indexOffset: Int {
        numericCast(layout.index_offset)
    }

    public var firstSubmapOffset: Int {
        numericCast(layout.first_submap_offset)
    }
}
