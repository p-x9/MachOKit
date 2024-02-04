//
//  ThreadCommand.swift
//
//
//  Created by p-x9 on 2023/11/30.
//  
//

import Foundation

public struct ThreadCommand: LoadCommandWrapper {
    public typealias Layout = thread_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension ThreadCommand {
    public func _flavor(cmdsStart: UnsafeRawPointer) -> UInt32? {
        guard Int(layout.cmdsize) >= layoutSize + MemoryLayout<UInt32>.size else {
            return nil
        }
        let flavor = cmdsStart
            .load(
                fromByteOffset: offset + layoutSize,
                as: UInt32.self
            )
        return flavor
    }

    public func count(cmdsStart: UnsafeRawPointer) -> UInt32? {
        guard Int(layout.cmdsize) >= layoutSize + 2 * MemoryLayout<UInt32>.size else {
            return nil
        }
        let count = cmdsStart
            .load(
                fromByteOffset: offset + layoutSize + MemoryLayout<UInt32>.size,
                as: UInt32.self
            )
        return count
    }

    public func state(cmdsStart: UnsafeRawPointer) -> Data? {
        guard let count = count(cmdsStart: cmdsStart) else {
            return nil
        }
        let stateSizeExpected = Int(count) * MemoryLayout<UInt32>.size
        let stateSize = Int(layout.cmdsize) - layoutSize - 2 * MemoryLayout<UInt32>.size
        guard stateSizeExpected == stateSize else { return nil }
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .advanced(by: 2 * MemoryLayout<UInt32>.size)

        return Data(
            bytes: ptr,
            count: stateSizeExpected
        )
    }
}

extension ThreadCommand {
    public func _flavor(in machO: MachOFile) -> UInt32? {
        guard Int(layout.cmdsize) >= layoutSize + MemoryLayout<UInt32>.size else {
            return nil
        }
        let offset = machO.cmdsStartOffset + offset + layoutSize
        var flavor: UInt32 =  machO.fileHandle.read(
            offset: numericCast(offset)
        )
        if machO.isSwapped { flavor = flavor.byteSwapped }
        return flavor
    }

    public func count(in machO: MachOFile) -> UInt32? {
        guard Int(layout.cmdsize) >= layoutSize + 2 * MemoryLayout<UInt32>.size else {
            return nil
        }
        let offset = machO.cmdsStartOffset + offset + layoutSize + MemoryLayout<UInt32>.size
        var count: UInt32 =  machO.fileHandle.read(
            offset: numericCast(offset)
        )
        if machO.isSwapped { count = count.byteSwapped }
        return count
    }

    public func state(in machO: MachOFile) -> Data? {
        guard let count = count(in: machO) else {
            return nil
        }
        let stateSizeExpected = Int(count) * MemoryLayout<UInt32>.size
        let stateSize = Int(layout.cmdsize) - layoutSize - 2 * MemoryLayout<UInt32>.size
        guard stateSizeExpected == stateSize else { return nil }
        let offset = machO.cmdsStartOffset + offset + layoutSize + 2 * MemoryLayout<UInt32>.size

        return machO.fileHandle.readData(
            offset: numericCast(offset),
            size: stateSizeExpected
        )
    }
}

extension ThreadCommand {
    public func flavor(
        cmdsStart: UnsafeRawPointer,
        cpuType: CPUType
    ) -> Flavor? {
        guard let rawValue = _flavor(cmdsStart: cmdsStart) else {
            return nil
        }
        return flavor(rawValue: rawValue, cpuType: cpuType)
    }

    public func flavor(
        in machO: MachOFile,
        cpuType: CPUType
    ) -> Flavor? {
        guard let rawValue = _flavor(in: machO) else {
            return nil
        }
        return flavor(rawValue: rawValue, cpuType: cpuType)
    }

    private func flavor(
        rawValue: UInt32,
        cpuType: CPUType
    ) -> Flavor? {
        switch cpuType {
        case .arm, .arm64, .arm64_32:
            let flavor = ARMThreadStateFlavor(rawValue: rawValue)
            if let flavor {
                return .arm(flavor)
            }
        case .i386, .x86:
            let flavor = i386ThreadStateFlavor(rawValue: rawValue)
            if let flavor {
                return .i386(flavor)
            }
        case .x86_64:
            let flavor = x86ThreadStateFlavor(rawValue: rawValue)
            if let flavor {
                return .x86_64(flavor)
            }
        default: break
        }
        return nil
    }
}

extension ThreadCommand {
    public enum Flavor: CustomStringConvertible {
        case arm(ARMThreadStateFlavor)
        case i386(i386ThreadStateFlavor)
        case x86_64(x86ThreadStateFlavor)

        public var description: String {
            switch self {
            case let .arm(flavor): flavor.description
            case let .i386(flavor): flavor.description
            case let .x86_64(flavor): flavor.description
            }
        }
    }
}
