//
//  SegmentCommand.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public protocol SegmentCommandProtocol: LoadCommandWrapper {
    associatedtype SectionType: LayoutWrapper
    var segmentName: String { get }
    var maxProtection: VMProtection { get }
    var initialProtection: VMProtection { get }
    var flags: SegmentCommandFlags { get }

    func sections(cmdsStart: UnsafeRawPointer) -> MemorySequence<SectionType>
    func sections(in machO: MachOFile) -> DataSequence<SectionType>
}

public struct SegmentCommand: SegmentCommandProtocol {
    public typealias Layout = segment_command
    public typealias SectionType = Section

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

public struct SegmentCommand64: SegmentCommandProtocol {
    public typealias Layout = segment_command_64
    public typealias SectionType = Section64

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

extension SegmentCommandProtocol {
    func _sections(
        cmdsStart: UnsafeRawPointer,
        numberOfElements: Int
    ) -> MemorySequence<SectionType> {
        let ptr = cmdsStart
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .assumingMemoryBound(to: SectionType.self)
        return .init(
            basePointer: ptr,
            numberOfElements: numberOfElements
        )
    }
}

extension SegmentCommand {
    public func sections(
        cmdsStart: UnsafeRawPointer
    ) -> MemorySequence<Section> {
        _sections(cmdsStart: cmdsStart, numberOfElements: Int(layout.nsects))
    }
}

extension SegmentCommand64 {
    public func sections(
        cmdsStart: UnsafeRawPointer
    ) -> MemorySequence<Section64> {
        _sections(cmdsStart: cmdsStart, numberOfElements: Int(layout.nsects))
    }
}

extension SegmentCommandProtocol {
    func _sections(
        in machO: MachOFile,
        numberOfElements: Int,
        swapHandler: (UnsafeMutablePointer<SectionType.Layout>, UInt32, NXByteOrder) -> Void
    ) -> DataSequence<SectionType> {
        let offset = machO.cmdsStartOffset + offset + layoutSize
        machO.fileHandle.seek(toFileOffset: UInt64(offset))
        let data = machO.fileHandle.readData(
            ofLength: numberOfElements * MemoryLayout<SectionType>.size
        )
        if machO.isSwapped {
            data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return }
                let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                    .assumingMemoryBound(to: SectionType.Layout.self)
                swapHandler(ptr, UInt32(numberOfElements), NXHostByteOrder())
            }
        }
        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }
}

extension SegmentCommand {
    public func sections(
        in machO: MachOFile
    ) -> DataSequence<Section> {
        _sections(
            in: machO,
            numberOfElements: Int(layout.nsects),
            swapHandler: swap_section
        )
    }
}

extension SegmentCommand64 {
    public func sections(
        in machO: MachOFile
    ) -> DataSequence<Section64> {
        _sections(
            in: machO,
            numberOfElements: Int(layout.nsects),
            swapHandler: swap_section_64
        )
    }
}
