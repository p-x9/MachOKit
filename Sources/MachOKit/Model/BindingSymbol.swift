//
//  BindingSymbol.swift
//  
//
//  Created by p-x9 on 2023/12/13.
//  
//

import Foundation

public struct BindingSymbol {
    public let type: BindType
    public let libraryOrdinal: UInt
    public let segmentIndex: UInt
    public let segmentOffset: UInt
    public let addend: Int
    public let symbolName: String
}

extension BindingSymbol {
    public func library(in machO: MachO) -> Dylib? {
        if libraryOrdinal == 0 {
            return Array(
                machO
                    .loadCommands
                    .infos(of: LoadCommand.idDylib)
            )
            .first?
            .dylib(cmdsStart: machO.cmdsStartPtr)
        }

        let index = Int(libraryOrdinal - 1)
        guard machO.dependencies.indices.contains(index) else {
            return nil
        }
        return machO.dependencies[index]
    }

    public func library(in machO: MachOFile) -> Dylib? {
        if libraryOrdinal == 0 {
            return Array(
                machO
                    .loadCommands
                    .infos(of: LoadCommand.idDylib)
            )
            .first?
            .dylib(in: machO)
        }

        let index = Int(libraryOrdinal - 1)
        guard machO.dependencies.indices.contains(index) else {
            return nil
        }
        return machO.dependencies[index]
    }
}

extension BindingSymbol {
    public func segment64(in machO: MachO) -> SegmentCommand64? {
        let segments = Array(machO.segments64)
        let index = Int(segmentIndex)
        guard segments.indices.contains(index) else { return nil }
        return segments[index]
    }

    public func segment32(in machO: MachO) -> SegmentCommand? {
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
    public func section64(in machO: MachO) -> Section64? {
        guard let segment = segment64(in: machO) else { return nil  }
        let sections = segment.sections(cmdsStart: machO.cmdsStartPtr)

        let segmentStart = UInt(segment.vmaddr)
        return sections.first(where: { section in
            let offset = UInt(section.layout.offset)
            let size = UInt(section.layout.size)
            if offset <= segmentStart + segmentOffset &&
                segmentStart + segmentOffset <= offset + size {
                return true
            } else {
                return false
            }
        })
    }

    public func section32(in machO: MachO) -> Section? {
        guard let segment = segment32(in: machO) else { return nil  }
        let sections = segment.sections(cmdsStart: machO.cmdsStartPtr)

        let segmentStart = UInt(segment.vmaddr)
        return sections.first(where: { section in
            let offset = UInt(section.layout.offset)
            let size = UInt(section.layout.size)
            if offset <= segmentStart + segmentOffset &&
                segmentStart + segmentOffset <= offset + size {
                return true
            } else {
                return false
            }
        })
    }

    public func section64(in machO: MachOFile) -> Section64? {
        guard let segment = segment64(in: machO) else { return nil }
        let sections = segment.sections(in: machO)

        let segmentStart = UInt(segment.fileoff)
        return sections.first(where: { section in
            let offset = UInt(section.layout.offset)
            let size = UInt(section.layout.size)
            if offset <= segmentStart + segmentOffset &&
                segmentStart + segmentOffset <= offset + size {
                return true
            } else {
                return false
            }
        })
    }

    public func section32(in machO: MachOFile) -> Section? {
        guard let segment = segment32(in: machO) else { return nil  }
        let sections = segment.sections(in: machO)

        let segmentStart = UInt(segment.fileoff)
        return sections.first(where: { section in
            let offset = UInt(section.layout.offset)
            let size = UInt(section.layout.size)
            if offset <= segmentStart + segmentOffset &&
                segmentStart + segmentOffset <= offset + size {
                return true
            } else {
                return false
            }
        })
    }
}

extension BindingSymbol {
    public func address(in machO: MachO) -> UInt? {
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
