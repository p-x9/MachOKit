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

extension DylibCommand {
    public var isDylibUseCommand: Bool {
        layout.dylib.timestamp == DYLIB_USE_MARKER
    }

    public func dylibUseCommand(in machO: MachOImage) -> DylibUseCommand? {
        guard isDylibUseCommand else { return nil }

        let ptr = machO.cmdsStartPtr
            .advanced(by: offset)
            .assumingMemoryBound(to: DylibUseCommand.Layout.self)
        return .init(ptr.pointee, offset: offset)
    }

    public func dylibUseCommand(in machO: MachOFile) -> DylibUseCommand? {
        guard isDylibUseCommand else { return nil }

        let offset = machO.cmdsStartOffset + offset
        let layout: DylibUseCommand.Layout = machO.fileHandle.read(
            offset: numericCast(offset),
            swapHandler: {
                guard machO.isSwapped else { return }
                return $0.withUnsafeBytes {
                    guard let baseAddress = $0.baseAddress else { return }
                    let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                        .assumingMemoryBound(to: dylib_use_command.self)
                    swap_dylib_use_command(ptr, NXHostByteOrder())
                }
            }
        )
        return .init(layout, offset: offset)
    }
}
