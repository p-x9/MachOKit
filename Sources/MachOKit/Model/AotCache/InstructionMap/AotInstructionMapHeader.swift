//
//  AotInstructionMapHeader.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/16
//  
//

import MachOKitC

public struct AotInstructionMapHeader: LayoutWrapper {
    public typealias Layout = aot_instruction_map_header

    public var layout: Layout
}
