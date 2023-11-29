//
//  RpathCommand.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation
import MachO

public struct RpathCommand: LoadCommandWrapper {
    public typealias Layout = rpath_command

    public let layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }

    public func path(cmdsStart: UnsafeRawPointer) -> String {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: Int(layout.path.offset))
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}
