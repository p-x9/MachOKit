//
//  DylibUseCommand.swift
//  MachOKit
//
//  Created by p-x9 on 2024/12/12
//
//

import Foundation

public struct DylibUseCommand: LoadCommandWrapper {
    public typealias Layout = dylib_use_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension DylibUseCommand {
    public var flags: DylibUseFlags {
        .init(rawValue: layout.flags)
    }
}

extension DylibUseCommand {
    public func dylib(cmdsStart: UnsafeRawPointer) -> Dylib {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: Int(layout.nameoff))
            .assumingMemoryBound(to: CChar.self)

        return .init(
            name: String(cString: ptr),
            timestamp: Date(timeIntervalSince1970: TimeInterval(layout.marker)),
            currentVersion: .init(layout.current_version),
            compatibilityVersion: .init(layout.compat_version)
        )
    }
}

extension DylibUseCommand {
    public func dylib(in machO: MachOFile) -> Dylib {
        let offset = machO.cmdsStartOffset + offset + Int(layout.nameoff)
        // swap is not needed
        let string = machO.fileHandle.readString(
            offset: numericCast(offset),
            size: Int(layout.cmdsize) - layoutSize
        ) ?? ""

        return .init(
            name: string,
            timestamp: Date(timeIntervalSince1970: TimeInterval(layout.marker)),
            currentVersion: .init(layout.current_version),
            compatibilityVersion: .init(layout.compat_version)
        )
    }
}

public func swap_dylib_use_command(
    _ dl: UnsafeMutablePointer<dylib_use_command>!,
    _ target_byte_sex: NXByteOrder
) {
    dl.pointee.cmd = dl.pointee.cmd.byteSwapped
    dl.pointee.cmdsize = dl.pointee.cmdsize.byteSwapped
    dl.pointee.nameoff = dl.pointee.nameoff.byteSwapped
    dl.pointee.marker = dl.pointee.marker.byteSwapped
    dl.pointee.current_version = dl.pointee.current_version.byteSwapped
    dl.pointee.compat_version = dl.pointee.compat_version.byteSwapped
    dl.pointee.flags = dl.pointee.flags.byteSwapped
}
