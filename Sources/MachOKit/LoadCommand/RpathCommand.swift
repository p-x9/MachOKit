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

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension RpathCommand {
    public func path(cmdsStart: UnsafeRawPointer) -> String {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: Int(layout.path.offset))
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}

extension RpathCommand {
    public func path(in machO: MachOFile) -> String {
        let offset = machO.cmdsStartOffset + offset + Int(layout.path.offset)
        machO.fileHandle.seek(toFileOffset: UInt64(offset))
        let data = machO.fileHandle.readData(
            ofLength: Int(layout.cmdsize) - layoutSize
        )
        // swap is not needed
        return data.withUnsafeBytes {
            if let baseAddress = $0.baseAddress {
                return String(cString: baseAddress.assumingMemoryBound(to: CChar.self))
            }
            return ""
        }
    }
}
