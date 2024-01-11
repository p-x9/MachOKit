//
//  DyldChainedStartsOffsets.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation
import MachOKitC

public struct DyldChainedStartsOffsets: LayoutWrapper {
    public typealias Layout = dyld_chained_starts_offsets

    public var layout: Layout
}
