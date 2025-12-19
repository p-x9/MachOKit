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
    public func compactEntries(in cache: AotCache) -> DataSequence<AotBranchDataIndexEntryCompact>? {
        guard header.kind == 1 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: UInt64(offset + AotBranchDataHeader.layoutSize),
            numberOfElements: numericCast(header.entry_count)
        )
    }

    public func entries(in cache: AotCache) -> DataSequence<AotBranchDataIndexEntry>? {
        guard header.kind == 2 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: UInt64(offset + AotBranchDataHeader.layoutSize),
            numberOfElements: numericCast(header.entry_count)
        )
    }

    public func extendedEntries(in cache: AotCache) -> DataSequence<AotBranchDataIndexEntryExtended>? {
        guard header.kind == 3 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: UInt64(offset + AotBranchDataHeader.layoutSize),
            numberOfElements: numericCast(header.entry_count)
        )
    }
}
