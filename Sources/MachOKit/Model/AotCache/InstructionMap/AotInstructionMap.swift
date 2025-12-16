//
//  AotInstructionMap.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/17
//  
//

import Foundation
import MachOKitC

public struct AotInstructionMap {
    public let header: AotInstructionMapHeader
    public let offset: Int
}

extension AotInstructionMap {
    public func entries(in cache: AotCache) -> DataSequence<AotInstructionMapIndexEntry> {
        cache.fileHandle.readDataSequence(
            offset: UInt64(offset + MemoryLayout<AotInstructionMapHeader>.size),
            numberOfElements: numericCast(header.entry_count)
        )
    }
}
