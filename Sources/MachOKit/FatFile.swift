//
//  FatFile.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

/// A representation of a Mach-O fat (universal) binary.
///
/// `FatFile` parses the fat header (`fat_header`) at the beginning of
/// the file, determines byte order, and provides access to each
/// architecture entry (`fat_arch` / `fat_arch_64`) contained within
/// the binary.
///
/// This type is responsible only for interpreting the fat container
/// itself. Actual Mach-O parsing is delegated to `MachOFile`.
public class FatFile {

    /// The file URL of the fat binary.
    let url: URL

    /// File handle used for reading the binary contents.
    let fileHandle: FileHandle

    /// Indicates whether the fat header and architecture entries
    /// are byte-swapped relative to the host byte order.
    ///
    /// This is determined from the magic value in the fat header
    /// and applied when parsing fields such as offsets and sizes.
    public private(set) var isSwapped: Bool

    /// The parsed fat header.
    ///
    /// If the header was stored in a different byte order, it is
    /// already swapped to host byte order when exposed here.
    public let header: FatHeader

    /// A Boolean value indicating whether this fat binary uses
    /// the 64-bit fat format (`fat_arch_64`).
    ///
    /// This is derived from the magic value in the fat header.
    public var is64bit: Bool { header.magic.is64BitFat }

    /// The size in bytes of the fat header.
    ///
    /// This corresponds to `sizeof(fat_header)`.
    public var headerSize: Int {
        MemoryLayout<fat_header>.size
    }

    /// The total size in bytes of all architecture entries.
    ///
    /// This is calculated as:
    /// `nfat_arch * sizeof(fat_arch[_64])`.
    public var archesSize: Int {
        Int(header.nfat_arch)
        * (is64bit
           ? MemoryLayout<fat_arch_64>.size
           : MemoryLayout<fat_arch>.size)
    }

    /// The file offset at which the architecture entries begin.
    ///
    /// In a fat binary, architecture entries immediately follow
    /// the fat header.
    public var archesStartOffset: Int {
        headerSize
    }

    /// The list of architecture entries contained in the fat binary.
    ///
    /// Each entry describes the CPU type, subtype, file offset,
    /// and size of an embedded Mach-O image.
    ///
    /// - Note: The returned `FatArch` values are already adjusted
    ///         for byte order if the fat header was swapped.
    public var arches: [FatArch] {
        let data = fileHandle.readData(
            offset: UInt64(archesStartOffset),
            size: archesSize
        )
        return header.arches(data: data, isSwapped: isSwapped)
    }

    /// Creates a `FatFile` by reading and parsing a fat binary
    /// at the specified file URL.
    ///
    /// This initializer reads the fat header, determines whether
    /// byte swapping is required, and normalizes the header to
    /// host byte order.
    ///
    /// - Parameter url: The file URL of the fat binary.
    /// - Throws: An error if the file cannot be opened or read.
    init(url: URL) throws {
        self.url = url
        self.fileHandle = try FileHandle(forReadingFrom: url)

        var header: FatHeader = fileHandle.read(
            offset: 0
        )

        let isSwapped = header.magic.isSwapped
        if isSwapped {
            swap_fat_header(&header.layout, NXHostByteOrder())
        }

        self.isSwapped = isSwapped
        self.header = header
    }

    /// Closes the underlying file handle.
    ///
    /// This is automatically called when the `FatFile` instance
    /// is deallocated.
    deinit {
        fileHandle.closeFile()
    }
}

extension FatFile {
    /// Creates `MachOFile` instances for all architectures
    /// contained in the fat binary.
    ///
    /// Each Mach-O file is initialized using the architecture's
    /// file offset within the fat container.
    ///
    /// - Returns: An array of `MachOFile` instances, one for each
    ///            architecture in the fat binary.
    /// - Throws: Any error thrown while initializing a `MachOFile`.
    public func machOFiles() throws -> [MachOFile] {
        try arches.map {
            try .init(
                url: url,
                headerStartOffset: Int($0.offset)
            )
        }
    }
}
