//
//  SegmentCommand.swift
//
//
//  Created by p-x9 on 2023/11/28.
//
//

import Foundation

public protocol SegmentCommandProtocol: LoadCommandWrapper {
    associatedtype SectionType: SectionProtocol

    var segmentName: String { get }
    var virtualMemoryAddress: Int { get }
    var virtualMemorySize: Int { get }
    var fileOffset: Int { get }
    var fileSize: Int { get }
    var maxProtection: VMProtection { get }
    var initialProtection: VMProtection { get }
    var numberOfSections: Int { get }
    var flags: SegmentCommandFlags { get }

    func startPtr(vmaddrSlide: Int) -> UnsafeRawPointer?
    func endPtr(vmaddrSlide: Int) -> UnsafeRawPointer?
    func sections(cmdsStart: UnsafeRawPointer) -> MemorySequence<SectionType>
    func sections(in machO: MachOFile) -> DataSequence<SectionType>
    func section(at offset: UInt, cmdsStart: UnsafeRawPointer) -> SectionType?
    func section(at offset: UInt, in machO: MachOFile) -> SectionType?
}

extension SegmentCommandProtocol {
    public func startPtr(vmaddrSlide: Int) -> UnsafeRawPointer? {
        let address = vmaddrSlide + virtualMemoryAddress
        return UnsafeRawPointer(bitPattern: address)
    }

    public func endPtr(vmaddrSlide: Int) -> UnsafeRawPointer? {
        guard let start = startPtr(vmaddrSlide: vmaddrSlide) else {
            return nil
        }
        return start + virtualMemorySize
    }
}

extension SegmentCommandProtocol {
    public func contains(unslidAddress address: UInt64) -> Bool {
        virtualMemoryAddress <= address && address < virtualMemoryAddress + virtualMemorySize
    }
}

public struct SegmentCommand: SegmentCommandProtocol {
    public typealias Layout = segment_command
    public typealias SectionType = Section

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    public var virtualMemoryAddress: Int {
        numericCast(layout.vmaddr)
    }

    public var virtualMemorySize: Int {
        numericCast(layout.vmsize)
    }

    public var fileOffset: Int {
        numericCast(layout.fileoff)
    }

    public var fileSize: Int {
        numericCast(layout.filesize)
    }

    public var maxProtection: VMProtection {
        .init(rawValue: layout.maxprot)
    }

    public var initialProtection: VMProtection {
        .init(rawValue: layout.initprot)
    }

    public var numberOfSections: Int {
        numericCast(layout.nsects)
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

    public var virtualMemoryAddress: Int {
        numericCast(layout.vmaddr)
    }

    public var virtualMemorySize: Int {
        numericCast(layout.vmsize)
    }

    public var fileOffset: Int {
        numericCast(layout.fileoff)
    }

    public var fileSize: Int {
        numericCast(layout.filesize)
    }

    public var maxProtection: VMProtection {
        .init(rawValue: layout.maxprot)
    }

    public var initialProtection: VMProtection {
        .init(rawValue: layout.initprot)
    }

    public var numberOfSections: Int {
        numericCast(layout.nsects)
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
        swapHandler: @escaping (UnsafeMutablePointer<SectionType.Layout>, UInt32, NXByteOrder) -> Void
    ) -> DataSequence<SectionType> {
        let offset = machO.cmdsStartOffset + offset + layoutSize

        return machO.fileHandle.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: numberOfElements,
            swapHandler: { data in
                guard machO.isSwapped else { return }
                data.withUnsafeBytes {
                    guard let baseAddress = $0.baseAddress else { return }
                    let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                        .assumingMemoryBound(to: SectionType.Layout.self)
                    swapHandler(ptr, UInt32(numberOfElements), NXHostByteOrder())
                }
            }
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

extension SegmentCommand {
    private func _section(
        at offset: UInt,
        segmentStart: UInt,
        sections: any Sequence<Section>
    ) -> Section? {
        sections.first(where: { section in
            let sectionStart = UInt(section.layout.offset)
            let size = UInt(section.layout.size)
            if sectionStart <= segmentStart + offset &&
                segmentStart + offset < sectionStart + size {
                return true
            } else {
                return false
            }
        })
    }

    /// Section at the specified offset
    /// - Parameters:
    ///   - offset: offset from start of segment
    ///   - cmdsStart: pointer at load commands start
    /// - Returns: located section
    public func section(
        at offset: UInt,
        cmdsStart: UnsafeRawPointer
    ) -> Section? {
        let sections = sections(cmdsStart: cmdsStart)
        return _section(
            at: offset,
            segmentStart: UInt(layout.vmaddr),
            sections: sections
        )
    }

    /// Section at the specified offset
    /// - Parameters:
    ///   - offset: offset from start of segment
    ///   - machO: machO file
    /// - Returns: located section
    public func section(
        at offset: UInt,
        in machO: MachOFile
    ) -> Section? {
        let sections = sections(in: machO)
        return _section(
            at: offset,
            segmentStart: UInt(layout.fileoff),
            sections: sections
        )
    }
}

extension SegmentCommand64 {
    private func _section(
        at offset: UInt,
        segmentStart: UInt,
        sections: any Sequence<Section64>
    ) -> Section64? {
        sections.first(where: { section in
            let sectionStart = UInt(section.layout.offset)
            let size = UInt(section.layout.size)
            if sectionStart <= segmentStart + offset &&
                segmentStart + offset < sectionStart + size {
                return true
            } else {
                return false
            }
        })
    }

    /// Section at the specified offset
    /// - Parameters:
    ///   - offset: offset from start of segment
    ///   - cmdsStart: pointer at load commands start
    /// - Returns: located section
    public func section(
        at offset: UInt,
        cmdsStart: UnsafeRawPointer
    ) -> Section64? {
        let sections = sections(cmdsStart: cmdsStart)
        return _section(
            at: offset,
            segmentStart: UInt(layout.vmaddr),
            sections: sections
        )
    }

    /// Section at the specified offset
    /// - Parameters:
    ///   - offset: offset from start of segment
    ///   - machO: machO file
    /// - Returns: located section
    public func section(
        at offset: UInt,
        in machO: MachOFile
    ) -> Section64? {
        let sections = sections(in: machO)
        return _section(
            at: offset,
            segmentStart: UInt(layout.fileoff),
            sections: sections
        )
    }
}
