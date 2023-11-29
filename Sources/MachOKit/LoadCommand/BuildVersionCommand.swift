//
//  BuildVersionCommand.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation
import MachO

public struct BuildVersionCommand: LoadCommandWrapper {
    public typealias Layout = build_version_command

    public let layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension BuildVersionCommand {
    public var platform: Platform {
        .init(rawValue: layout.platform) ?? .unknown
    }
    
    public var minos: Version {
        .init(
            major: Int((layout.minos & 0xFFFF0000) >> 16),
            minor: Int((layout.minos & 0x0000FF00) >> 8),
            patch: Int(layout.minos & 0x000000FF)
        )
    }

    public var sdk: Version {
        .init(
            major: Int((layout.sdk & 0xFFFF0000) >> 16),
            minor: Int((layout.sdk & 0x0000FF00) >> 8),
            patch: Int(layout.sdk & 0x000000FF)
        )
    }

    public func tools(
        cmdsStart: UnsafeRawPointer
    ) -> MemorySequence<BuildToolVersion> {
        let base = cmdsStart
            .advanced(by: offset)
            .advanced(by: MemoryLayout<Layout>.size)
            .assumingMemoryBound(to: BuildToolVersion.self)
        return .init(
            basePointer: base,
            numberOfElements: Int(layout.ntools)
        )
    }
}
