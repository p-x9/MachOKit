//
//  DyldChainedStartsInSegment.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation
import MachOKitC

public struct DyldChainedStartsInSegment: LayoutWrapper {
    public typealias Layout = dyld_chained_starts_in_segment

    public var layout: Layout
    public let offset: Int

    public var pointerFormat: DyldChainedPointerFormat? {
        .init(rawValue: layout.pointer_format)
    }
}

extension DyldChainedStartsInSegment {
    public var swapped: Self {
        var layout = self.layout
        layout.size = layout.size.byteSwapped
        layout.page_size = layout.page_size.byteSwapped
        layout.pointer_format = layout.pointer_format.byteSwapped
        layout.segment_offset = layout.segment_offset.byteSwapped
        layout.max_valid_pointer = layout.max_valid_pointer.byteSwapped
        layout.page_count = layout.page_count.byteSwapped
        layout.page_start = layout.page_start.byteSwapped
        return .init(layout: layout, offset: offset)
    }
}
