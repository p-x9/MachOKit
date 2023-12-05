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

    public var layout: Layout
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
        .init(layout.minos)
    }

    public var sdk: Version {
        .init(layout.sdk)
    }
}

extension BuildVersionCommand {
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

extension BuildVersionCommand {
    public func tools(
        in machO: MachOFile
    ) -> DataSequence<BuildToolVersion> {
        let offset = machO.cmdsStartOffset + offset + MemoryLayout<Layout>.size
        machO.fileHandle.seek(toFileOffset: UInt64(offset))
        let data = machO.fileHandle.readData(
            ofLength: Int(layout.ntools) * MemoryLayout<BuildToolVersion>.size
        )
        if machO.isSwapped {
            data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return }
                let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                    .assumingMemoryBound(to: build_tool_version.self)
                swap_build_tool_version(ptr, layout.ntools, NXHostByteOrder())
            }
        }

        return .init(
            data: data,
            numberOfElements: Int(layout.ntools)
        )
    }
}
