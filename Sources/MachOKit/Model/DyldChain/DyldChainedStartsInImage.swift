//
//  DyldChainedStartsInImage.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation
import MachOKitC

public struct DyldChainedStartsInImage: LayoutWrapper, Sendable {
    public typealias Layout = dyld_chained_starts_in_image

    public var layout: Layout
    public let offset: Int
}

extension DyldChainedStartsInImage {
    public var swapped: Self {
        var layout = self.layout
        layout.seg_count = layout.seg_count.byteSwapped
        layout.seg_info_offset = layout.seg_info_offset.byteSwapped
        return .init(layout: layout, offset: offset)
    }
}
