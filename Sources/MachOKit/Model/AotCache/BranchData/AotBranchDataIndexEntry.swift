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
