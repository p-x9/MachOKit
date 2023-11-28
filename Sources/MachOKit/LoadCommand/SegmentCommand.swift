//
//  SegmentCommand.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

@dynamicMemberLookup
public protocol LoadCommandWrapper {
    associatedtype Layout

    var layout: Layout { get }
    var offset: Int { get }
}

extension LoadCommandWrapper {
    public subscript<Value>(dynamicMember keyPath: KeyPath<Layout, Value>) -> Value {
        layout[keyPath: keyPath]
    }
}

public struct SegmentCommand: LoadCommandWrapper {
    public typealias Layout = segment_command

    public let layout: Layout
    public var offset: Int // offset from mach header trailing

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

public struct SegmentCommand64: LoadCommandWrapper {
    public typealias Layout = segment_command_64

    public let layout: Layout
    public var offset: Int // offset from mach header trailing

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}
