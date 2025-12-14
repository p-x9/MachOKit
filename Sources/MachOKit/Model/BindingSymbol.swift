//
//  BindingSymbol.swift
//
//
//  Created by p-x9 on 2023/12/13.
//
//

import Foundation

public struct BindingSymbol: Sendable {
    public let type: BindType
    public let libraryOrdinal: Int
    public let segmentIndex: UInt
    public let segmentOffset: UInt
    public let addend: Int
    public let symbolName: String
}

extension BindingSymbol {
    public var bindSpecial: BindSpecial? {
        .init(rawValue: BindSpecial.RawValue(libraryOrdinal))
    }

    public func library(in machO: MachOImage) -> Dylib? {
        if let bindSpecial {
            if bindSpecial == .dylib_self {
                let idDylib = machO.loadCommands.idDylib
                return idDylib?.dylib(cmdsStart: machO.cmdsStartPtr)
            }
            return nil
        }

        let index = Int(libraryOrdinal - 1)
        guard machO.dependencies.indices.contains(index) else {
            return nil
        }
        return machO.dependencies[index].dylib
    }

    public func library(in machO: MachOFile) -> Dylib? {
        if let bindSpecial {
            if bindSpecial == .dylib_self {
                let idDylib = machO.loadCommands.idDylib
                return idDylib?.dylib(in: machO)
            }
        }

        let index = Int(libraryOrdinal - 1)
        guard machO.dependencies.indices.contains(index) else {
            return nil
        }
        return machO.dependencies[index].dylib
    }
}

extension BindingSymbol {
    public func segment64(in machO: MachOImage) -> SegmentCommand64? {
        let segments = Array(machO.segments64)
        let index = Int(segmentIndex)
        guard segments.indices.contains(index) else { return nil }
        return segments[index]
    }

    public func segment32(in machO: MachOImage) -> SegmentCommand? {
        let segments = Array(machO.segments32)
        let index = Int(segmentIndex)
        guard segments.indices.contains(index) else { return nil }
        return segments[index]
    }

    public func segment64(in machO: MachOFile) -> SegmentCommand64? {
        let segments = Array(machO.segments64)
        let index = Int(segmentIndex)
        guard segments.indices.contains(index) else { return nil }
        return segments[index]
    }

    public func segment32(in machO: MachOFile) -> SegmentCommand? {
        let segments = Array(machO.segments32)
        let index = Int(segmentIndex)
        guard segments.indices.contains(index) else { return nil }
        return segments[index]
    }
}

extension  BindingSymbol {
    public func section64(in machO: MachOImage) -> Section64? {
        guard let segment = segment64(in: machO) else { return nil  }
        return segment.section(
            at: segmentOffset,
            cmdsStart: machO.cmdsStartPtr
        )
    }

    public func section32(in machO: MachOImage) -> Section? {
        guard let segment = segment32(in: machO) else { return nil  }
        return segment.section(
            at: segmentOffset,
            cmdsStart: machO.cmdsStartPtr
        )
    }

    public func section64(in machO: MachOFile) -> Section64? {
        guard let segment = segment64(in: machO) else { return nil }
        return segment.section(at: segmentOffset, in: machO)
    }

    public func section32(in machO: MachOFile) -> Section? {
        guard let segment = segment32(in: machO) else { return nil  }
        return segment.section(at: segmentOffset, in: machO)
    }
}

extension BindingSymbol {
    public func address(in machO: MachOImage) -> UInt? {
        if machO.is64Bit, let segment = segment64(in: machO) {
            return UInt(segment.vmaddr) + segmentOffset
        } else if let segment = segment32(in: machO) {
            return UInt(segment.vmaddr) + segmentOffset
        }
        return nil
    }

    public func address(in machO: MachOFile) -> UInt? {
        if machO.is64Bit, let segment = segment64(in: machO) {
            return UInt(segment.vmaddr) + segmentOffset
        } else if let segment = segment32(in: machO) {
            return UInt(segment.vmaddr) + segmentOffset
        }
        return nil
    }
}
