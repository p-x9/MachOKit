//
//  DyldChainedStartsInImage.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation
import MachOKitC

public struct DyldChainedStartsInImage: LayoutWrapper {
    public typealias Layout = dyld_chained_starts_in_image

    public var layout: Layout
    public let offset: Int
}
