//
//  SegmentCommand.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public struct SegmentCommand: LoadCommandWrapper {
    public typealias Layout = segment_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    public var maxProtection: VMProtection {
        .init(rawValue: layout.maxprot)
    }

    public var initialProtection: VMProtection {
        .init(rawValue: layout.initprot)
    }

    public var flags: SegmentCommandFlags {
        .init(rawValue: layout.flags)
    }

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

public struct SegmentCommand64: LoadCommandWrapper {
    public typealias Layout = segment_command_64

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    public var maxProtection: VMProtection {
        .init(rawValue: layout.maxprot)
    }

    public var initialProtection: VMProtection {
        .init(rawValue: layout.initprot)
    }

    public var flags: SegmentCommandFlags {
        .init(rawValue: layout.flags)
    }

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension SegmentCommand {
    public func sections(
        cmdsStart: UnsafeRawPointer
    ) -> MemorySequence<Section> {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: MemoryLayout<segment_command>.size)
            .assumingMemoryBound(to: Section.self)
        return .init(
            basePointer: ptr,
            numberOfElements: Int(layout.nsects)
        )
    }
}

extension SegmentCommand64 {
    public func sections(
        cmdsStart: UnsafeRawPointer
    ) -> MemorySequence<Section64> {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: MemoryLayout<segment_command_64>.size)
            .assumingMemoryBound(to: Section64.self)
        return .init(
            basePointer: ptr,
            numberOfElements: Int(layout.nsects)
        )
    }
}

extension SegmentCommand {
    public func sections(
        in machO: MachOFile
    ) -> DataSequence<Section> {
        let offset = machO.cmdsStartOffset + offset + MemoryLayout<segment_command>.size
        machO.fileHandle.seek(toFileOffset: UInt64(offset))
        let data = machO.fileHandle.readData(
            ofLength: Int(layout.nsects) * MemoryLayout<section>.size
        )
        if machO.isSwapped {
            data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return }
                let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                    .assumingMemoryBound(to: section.self)
                swap_section(ptr, layout.nsects, NXHostByteOrder())
            }
        }
        return .init(
            data: data,
            numberOfElements: Int(layout.nsects)
        )
    }
}

extension SegmentCommand64 {
    public func sections(
        in machO: MachOFile
    ) -> DataSequence<Section64> {
        let offset = machO.cmdsStartOffset + offset + MemoryLayout<segment_command_64>.size
        machO.fileHandle.seek(toFileOffset: UInt64(offset))
        let data = machO.fileHandle.readData(
            ofLength: Int(layout.nsects) * MemoryLayout<section_64>.size
        )
        if machO.isSwapped {
            data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return }
                let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                    .assumingMemoryBound(to: section_64.self)
                swap_section_64(ptr, layout.nsects, NXHostByteOrder())
            }
        }
        return .init(
            data: data,
            numberOfElements: Int(layout.nsects)
        )
    }
}
