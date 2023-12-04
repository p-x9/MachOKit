//
//  LoadCommandInfo.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public struct LoadCommandInfo<Layout>: LoadCommandWrapper {
    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}
