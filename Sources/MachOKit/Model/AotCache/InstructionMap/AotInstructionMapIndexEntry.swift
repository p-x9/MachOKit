//
//  AotInstructionMapIndexEntry.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/16
//  
//

import MachOKitC

public struct AotInstructionMapIndexEntry: LayoutWrapper {
    public typealias Layout = aot_instruction_map_index_entry

    public var layout: Layout
}
