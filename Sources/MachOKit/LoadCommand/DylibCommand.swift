//
//  DylibCommand.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public struct DylibCommand: LoadCommandWrapper {
    public typealias Layout = dylib_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension DylibCommand {
    public func dylib(cmdsStart: UnsafeRawPointer) -> Dylib {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: Int(layout.dylib.name.offset))
            .assumingMemoryBound(to: CChar.self)

        return .init(
            name: String(cString: ptr),
            timestamp: Date(timeIntervalSince1970: TimeInterval(layout.dylib.timestamp)),
            currentVersion: .init(layout.dylib.current_version),
            compatibilityVersion: .init(layout.dylib.compatibility_version)
        )
    }
}

extension DylibCommand {
    public func dylib(in machO: MachOFile) -> Dylib {
        let offset = machO.cmdsStartOffset + offset + Int(layout.dylib.name.offset)
        // swap is not needed
        let string = machO.fileHandle.readString(
            offset: numericCast(offset),
            size: Int(layout.cmdsize) - layoutSize
        ) ?? ""

        return .init(
            name: string,
            timestamp: Date(timeIntervalSince1970: TimeInterval(layout.dylib.timestamp)),
            currentVersion: .init(layout.dylib.current_version),
            compatibilityVersion: .init(layout.dylib.compatibility_version)
        )
    }
}
