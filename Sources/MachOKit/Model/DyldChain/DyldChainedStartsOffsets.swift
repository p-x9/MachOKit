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

extension DyldChainedStartsOffsets {
    public var swapped: Self {
        var layout = self.layout
        layout.pointer_format = layout.pointer_format.byteSwapped
        layout.starts_count = layout.starts_count.byteSwapped
        layout.chain_starts = layout.chain_starts.byteSwapped
        return .init(layout: layout)
    }
}
