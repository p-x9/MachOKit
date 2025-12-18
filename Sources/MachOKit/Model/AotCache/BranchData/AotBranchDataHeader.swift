//
//  AotBranchDataHeader.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/18
//  
//

import MachOKitC

public struct AotBranchDataHeader: LayoutWrapper {
    public typealias Layout = aot_branch_data_header

    public var layout: Layout
}
