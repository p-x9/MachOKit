//
//  AotBranchData.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/18
//  
//

import MachOKitC

public struct AotBranchData {
    public let header: AotBranchDataHeader
    public let offset: Int
}

extension AotBranchData {
    public func entries(in cache: AotCache) -> DataSequence<AotBranchDataIndexEntry>? {
        guard header.kind == 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: UInt64(offset + MemoryLayout<AotBranchDataHeader>.size),
            numberOfElements: numericCast(header.entry_count)
        )
    }

    public func compactEntries(in cache: AotCache) -> DataSequence<AotBranchDataIndexEntryCompact>? {
        guard header.kind > 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: UInt64(offset + MemoryLayout<AotBranchDataHeader>.size - MemoryLayout<AotBranchDataIndexEntryCompact>.size),
            numberOfElements: numericCast(header.entry_count)
        )
    }
}
