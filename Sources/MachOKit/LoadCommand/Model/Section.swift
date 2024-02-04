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
    var offset: Int { get }
    var size: Int { get }
    var flags: SectionFlags { get }

    var indirectSymbolIndex: Int? { get }
    var numberOfIndirectSymbols: Int? { get }

    func startPtr(
        in segment: any SegmentCommandProtocol,
        vmaddrSlide: Int
    ) -> UnsafeRawPointer?

    /// returns nil except when type is `cstring_literals
    func strings(
        in segment: any SegmentCommandProtocol,
        vmaddrSlide: Int
    ) -> MachOImage.Strings?

    /// returns nil except when type is `cstring_literals
    func strings(in machO: MachOFile) -> MachOFile.Strings?

    /// relocation informations.
    /// (contains only in object file (.o))
    ///
    /// It can also be obtained with the following command
    /// ```sh
    /// otool -r <path to object file>
    /// ```
    func relocations(in machO: MachOFile) -> DataSequence<Relocation>
}

extension SectionProtocol {
    public func startPtr(in segment: any SegmentCommandProtocol, vmaddrSlide: Int) -> UnsafeRawPointer? {
        segment.startPtr(vmaddrSlide: vmaddrSlide)?
            .advanced(by: offset)
    }
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

    public var offset: Int {
        numericCast(layout.offset)
    }

    public var size: Int {
        numericCast(layout.size)
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

    public var offset: Int {
        numericCast(layout.offset)
    }

    public var size: Int {
        numericCast(layout.size)
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
    public func strings(
        in segment: any SegmentCommandProtocol,
        vmaddrSlide: Int
    ) -> MachOImage.Strings? {
        guard flags.type == .cstring_literals else { return nil }
        guard let basePointer = startPtr(
            in: segment,
            vmaddrSlide: vmaddrSlide
        ) else {
            return nil
        }
        let tableSize = size
        return MachOImage.Strings(
            basePointer: basePointer.assumingMemoryBound(to: CChar.self),
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
    public func strings(in machO: MachOFile) -> MachOFile.Strings? {
        _strings(in: machO, sectionOffset: layout.offset, sectionSize: UInt64(layout.size))
    }
}

extension Section64 {
    public func strings(in machO: MachOFile) -> MachOFile.Strings? {
        _strings(in: machO, sectionOffset: layout.offset, sectionSize: UInt64(layout.size))
    }
}

extension SectionProtocol {
    fileprivate func _relocations(
        in machO: MachOFile,
        reloff: UInt32,
        nreloc: UInt32
    ) -> DataSequence<Relocation> {
        machO.fileHandle.readDataSequence(
            offset: numericCast(reloff),
            numberOfElements: numericCast(nreloc),
            swapHandler: { data in
                guard machO.isSwapped else { return }
                data.withUnsafeMutableBytes {
                    guard let baseAddress = $0.baseAddress else { return }
                    let ptr = baseAddress
                        .assumingMemoryBound(to: relocation_info.self)
                    swap_relocation_info(ptr, nreloc, NXHostByteOrder())
                }
            }
        )
    }
}

extension Section64 {
    public func relocations(
        in machO: MachOFile
    ) -> DataSequence<Relocation> {
        _relocations(
            in: machO,
            reloff: layout.reloff,
            nreloc: layout.nreloc
        )
    }
}

extension Section {
    public func relocations(
        in machO: MachOFile
    ) -> DataSequence<Relocation> {
        _relocations(
            in: machO,
            reloff: layout.reloff,
            nreloc: layout.nreloc
        )
    }
}
