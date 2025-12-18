//
//  AotBranchDataIndexEntryCompact.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/18
//  
//

import MachOKitC

public struct AotBranchDataIndexEntryCompact: LayoutWrapper {
    public typealias Layout = aot_branch_data_index_entry_compact

    public var layout: Layout
}
