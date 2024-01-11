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
