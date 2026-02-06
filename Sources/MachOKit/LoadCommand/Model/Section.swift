//
//  Section.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public protocol SectionProtocol: LayoutWrapper, Sendable {
    /// Name of this section
    var sectionName: String { get }
    // Segment name this section goes in
    var segmentName: String { get }
    /// Memory address
    var address: Int { get }
    /// Size in bytes
    var size: Int { get }
    /// FIle offset
    var offset: Int { get }
    /// Section alignment (power of 2)
    var align: Int { get }
    /// Section type and attributes
    var flags: SectionFlags { get }

    /// Start of the index of the indirect symbol this section is responsible for.
    /// Returns nil unless the section type is either .lazy_symbol_pointers, non_lazy_symbol_pointers, .lazy_dylib_symbol_pointers, or .symbol_stubs.
    var indirectSymbolIndex: Int? { get }

    /// Number of the indirect symbols this section is responsible for.
    /// Returns nil unless the section type is either .lazy_symbol_pointers, non_lazy_symbol_pointers, .lazy_dylib_symbol_pointers, or .symbol_stubs.
    var numberOfIndirectSymbols: Int? { get }

    /// Get the pointer where this section starts
    /// - Parameters:
    ///   - vmaddrSlide: slide
    /// - Returns: Pointer where this section starts
    func startPtr(vmaddrSlide: Int) -> UnsafeRawPointer?

    /// Get the data in this section as a string table
    ///
    /// returns nil except when type is `cstring_literals
    ///
    /// - Parameters:
    ///   - vmaddrSlide: slide
    /// - Parameter machO: MachOImage to which `self` belongs
    /// - Returns: string table
    func strings(in machO: MachOImage) -> MachOImage.Strings?

    /// Get the data in this section as a string table
    ///
    /// returns nil except when type is `cstring_literals
    ///
    /// - Parameter machO: MachOFile to which `self` belongs
    /// - Returns: string table
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
    /// Get the pointer where this section starts
    /// - Parameters:
    ///   - segment: Segment to which this section belongs
    ///   - vmaddrSlide: slide
    /// - Returns: Pointer where this section starts
    @available(*, deprecated, renamed: "startPtr(vmaddrSlide:)", message: "No need to provide segment.")
    public func startPtr(in segment: any SegmentCommandProtocol, vmaddrSlide: Int) -> UnsafeRawPointer? {
        segment.startPtr(vmaddrSlide: vmaddrSlide)?
            .advanced(by: -segment.fileOffset)
            .advanced(by: offset)
    }

    public func startPtr(vmaddrSlide: Int) -> UnsafeRawPointer? {
        let address = vmaddrSlide + address
        return UnsafeRawPointer(bitPattern: address)
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

    public var address: Int {
        numericCast(layout.addr)
    }

    public var size: Int {
        numericCast(layout.size)
    }

    public var offset: Int {
        numericCast(layout.offset)
    }

    public var align: Int {
        numericCast(layout.align)
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

    public var address: Int {
        numericCast(layout.addr)
    }

    public var size: Int {
        numericCast(layout.size)
    }

    public var offset: Int {
        numericCast(layout.offset)
    }

    public var align: Int {
        numericCast(layout.align)
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
    /// Get the data in this section as a string table
    ///
    /// returns nil except when type is `cstring_literals
    ///
    /// - Parameters:
    ///   - segment: sgment to which this section belongs
    ///   - vmaddrSlide: slide
    /// - Returns: string table
    @available(*, unavailable, renamed: "strings(in:)")
    public func strings(
        in segment: any SegmentCommandProtocol,
        vmaddrSlide: Int
    ) -> MachOImage.Strings? {
        fatalError("This API has been removed. Use `strings(in:)` with a MachOImage instance instead.")
    }

    @available(*, unavailable, renamed: "strings(in:)")
    public func strings(
        vmaddrSlide: Int
    ) -> MachOImage.Strings? {
        fatalError("This API has been removed. Use `strings(in:)` with a MachOImage instance instead.")
    }

    public func strings(in machO: MachOImage) -> MachOImage.Strings? {
        guard flags.type == .cstring_literals else { return nil }
        guard let vmaddrSlide = machO.vmaddrSlide else { return nil }
        guard let basePointer = startPtr(
            vmaddrSlide: vmaddrSlide
        ) else {
            return nil
        }
        let tableSize = size
        return MachOImage.Strings(
            basePointer: basePointer.assumingMemoryBound(to: UInt8.self),
            offset: Int(bitPattern: basePointer) - Int(bitPattern: machO.ptr),
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
            size: tableSize,
            isSwapped: machO.isSwapped
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
