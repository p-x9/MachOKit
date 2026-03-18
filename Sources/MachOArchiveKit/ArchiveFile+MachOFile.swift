//
//  ArchiveFile+MachOFile.swift
//  MachOKit
//
//  Created by p-x9 on 2026/03/17
//  
//

import MachOKit
import ObjectArchiveKit

extension ArchiveFile {
    /// Creates `MachOFile` instances for all Mach-O members contained in the archive.
    ///
    /// Non-Mach-O members such as symbol tables are skipped automatically.
    ///
    /// - Returns: An array of `MachOFile` instances for members whose payload starts with a Mach-O magic.
    /// - Throws: Any error thrown while initializing a `MachOFile`.
    public func machOFiles() throws -> [MachOFile] {
        try members.compactMap { member in
            guard let dataOffset = member.dataOffset(in: self) else {
                throw ObjectArchiveKitError.invalidHeader
            }
            return try? MachOFile(
                url: url,
                imagePath: member.name(in: self),
                headerStartOffset: dataOffset + headerStartOffset,
                headerStartOffsetInCache: 0
            )
        }
    }
}
