//
//  FatFile+Archive.swift
//  MachOKit
//
//  Created by p-x9 on 2026/03/17
//  
//

import MachOKit
import ObjectArchiveKit

extension FatFile {
    /// Creates `ArchiveFile` instances for all architectures
    /// whose slice payload is a Unix `ar` archive.
    ///
    /// This is useful for fat static libraries where each architecture
    /// slice contains a separate archive.
    ///
    /// - Returns: An array of `ArchiveFile` instances for archive slices.
    /// - Throws: Any error thrown while initializing an `ArchiveFile`.
    public func archiveFiles() throws -> [ArchiveFile] {
        try arches.compactMap { arch in
            try ArchiveFile(
                url: url,
                headerStartOffset: numericCast(arch.offset),
                size: Int(arch.size)
            )
        }
    }
}
