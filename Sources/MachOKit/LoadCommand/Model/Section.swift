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

    var indirectSymbolIndex: Int? { get }
    var numberOfIndirectSymbols: Int? { get }

    /// returns nil except when type is `cstring_literals
    func strings(ptr: UnsafeRawPointer) -> MachOImage.Strings?

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

    public var indirectSymbolIndex: Int? {
        let types: [SectionType] = [
            .lazy_symbol_pointers,
            .non_lazy_symbol_pointers,
            .lazy_dylib_symbol_pointers,
            .symbol_stubs
        ]
        guard let type = flags.type,
              types.contains(type) else {
            return nil
        }
        return numericCast(layout.reserved1)
    }

    public var numberOfIndirectSymbols: Int? {
        guard let type = flags.type,
              indirectSymbolIndex != nil else {
            return nil
        }
        if type == .symbol_stubs {
            return numericCast(layout.size) / numericCast(layout.reserved2)
        } else {
            return numericCast(layout.size) / MemoryLayout<pointer_t>.size
        }
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

    public var indirectSymbolIndex: Int? {
        let types: [SectionType] = [
            .lazy_symbol_pointers,
            .non_lazy_symbol_pointers,
            .lazy_dylib_symbol_pointers,
            .symbol_stubs
        ]
        guard let type = flags.type,
              types.contains(type) else {
            return nil
        }
        return numericCast(layout.reserved1)
    }

    public var numberOfIndirectSymbols: Int? {
        guard let type = flags.type,
              indirectSymbolIndex != nil else {
            return nil
        }
        if type == .symbol_stubs {
            return numericCast(layout.size) / numericCast(layout.reserved2)
        } else {
            return numericCast(layout.size) / MemoryLayout<pointer_t>.size
        }
    }
}

extension SectionProtocol {
    fileprivate func _strings(
        ptr: UnsafeRawPointer,
        sectionOffset: UInt32,
        sectionSize: UInt64
    ) -> MachOImage.Strings? {
        guard flags.type == .cstring_literals else { return nil }
        let basePointer = ptr
            .advanced(by: numericCast(sectionOffset))
            .assumingMemoryBound(to: CChar.self)
        let tableSize = Int(sectionSize)
        return MachOImage.Strings(
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
    public func strings(ptr: UnsafeRawPointer) -> MachOImage.Strings? {
        _strings(ptr: ptr, sectionOffset: layout.offset, sectionSize: UInt64(layout.size))
    }

    public func strings(in machO: MachOFile) -> MachOFile.Strings? {
        _strings(in: machO, sectionOffset: layout.offset, sectionSize: UInt64(layout.size))
    }
}

extension Section64 {
    public func strings(ptr: UnsafeRawPointer) -> MachOImage.Strings? {
        _strings(ptr: ptr, sectionOffset: layout.offset, sectionSize: layout.size)
    }

    public func strings(in machO: MachOFile) -> MachOFile.Strings? {
        _strings(in: machO, sectionOffset: layout.offset, sectionSize: UInt64(layout.size))
    }
}
