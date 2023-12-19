//
//  Section.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public protocol SectionProtocol: LayoutWrapper {
    var sectionName: String { get }
    var segmentName: String { get }
    var flags: SectionFlags { get }

    /// returns nil except when type is `cstring_literals
    func strings(ptr: UnsafeRawPointer) -> MachO.Strings?

    /// returns nil except when type is `cstring_literals
    func strings(in machO: MachOFile) -> MachOFile.Strings?
}

public struct Section: SectionProtocol {
    public typealias Layout = section

    public var layout: Layout
}

extension Section {
    public var sectionName: String {
        .init(tuple: layout.sectname)
    }

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    public var flags: SectionFlags {
        .init(rawValue: layout.flags)
    }
}

public struct Section64: SectionProtocol {
    public typealias Layout = section_64

    public var layout: Layout
}

extension Section64 {
    public var sectionName: String {
        .init(tuple: layout.sectname)
    }

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    public var flags: SectionFlags {
        .init(rawValue: layout.flags)
    }
}

extension SectionProtocol {
    fileprivate func _strings(
        ptr: UnsafeRawPointer,
        sectionOffset: UInt32,
        sectionSize: UInt64
    ) -> MachO.Strings? {
        guard flags.type == .cstring_literals else { return nil }
        let basePointer = ptr
            .advanced(by: numericCast(sectionOffset))
            .assumingMemoryBound(to: CChar.self)
        let tableSize = Int(sectionSize)
        return MachO.Strings(
            basePointer: basePointer,
            tableSize: tableSize
        )
    }

    fileprivate func _strings(
        in machO: MachOFile,
        sectionOffset: UInt32,
        sectionSize: UInt64
    ) -> MachOFile.Strings? {
        guard flags.type == .cstring_literals else {
            return nil
        }
        let startOffset = machO.headerStartOffset + numericCast(sectionOffset)
        let tableSize = Int(sectionSize)

        return MachOFile.Strings(
            machO: machO,
            offset: startOffset,
            size: tableSize
        )
    }
}

extension Section {
    public func strings(ptr: UnsafeRawPointer) -> MachO.Strings? {
        _strings(ptr: ptr, sectionOffset: layout.offset, sectionSize: UInt64(layout.size))
    }

    public func strings(in machO: MachOFile) -> MachOFile.Strings? {
        _strings(in: machO, sectionOffset: layout.offset, sectionSize: UInt64(layout.size))
    }
}

extension Section64 {
    public func strings(ptr: UnsafeRawPointer) -> MachO.Strings? {
        _strings(ptr: ptr, sectionOffset: layout.offset, sectionSize: layout.size)
    }

    public func strings(in machO: MachOFile) -> MachOFile.Strings? {
        _strings(in: machO, sectionOffset: layout.offset, sectionSize: UInt64(layout.size))
    }
}
