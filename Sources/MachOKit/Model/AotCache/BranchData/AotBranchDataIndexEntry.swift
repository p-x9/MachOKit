//
//  AotBranchDataIndexEntry.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/18
//  
//

import MachOKitC

public struct AotBranchDataIndexEntry: LayoutWrapper {
    public typealias Layout = aot_branch_data_index_entry

    public var layout: Layout
}

public struct AotBranchDataIndexEntryCompact: LayoutWrapper {
    public typealias Layout = aot_branch_data_index_entry_compact

    public var layout: Layout
}

public struct AotBranchDataIndexEntryExtended: LayoutWrapper {
    public typealias Layout = aot_branch_data_index_entry_extended

    public var layout: Layout
}
