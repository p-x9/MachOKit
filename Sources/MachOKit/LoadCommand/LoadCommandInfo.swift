//
//  LoadCommandInfo.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public struct LoadCommandInfo<Layout: Sendable>: LoadCommandWrapper {
    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    /// Creates a command wrapper from its C layout.
    /// - Parameter offset: Byte offset from the start of the load-command region,
    ///   immediately after the Mach-O header.
    public init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}
