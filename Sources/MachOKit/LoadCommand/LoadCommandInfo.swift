//
//  LoadCommandInfo.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

@dynamicMemberLookup
public struct LoadCommandInfo<Layout> {
    public let layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<Layout, Value>) -> Value {
        layout[keyPath: keyPath]
    }
}

extension LoadCommandInfo<segment_command> {
    public var segmentName: String {
        .init(tuple: layout.segname)
    }
}

extension LoadCommandInfo<segment_command_64> {
    public var segmentName: String {
        .init(tuple: layout.segname)
    }
}
