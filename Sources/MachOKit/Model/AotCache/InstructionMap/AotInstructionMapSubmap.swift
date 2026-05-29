//
//  AotInstructionMapSubmap.swift
//  MachOKit
//
//  Created by p-x9 on 2026/05/26
//  
//

public struct AotInstructionMapSubmap: Sendable {
    public let index: Int
    public let offset: Int
}

extension AotInstructionMapSubmap {
    public func entries(
        for map: AotInstructionMap,
        in cache: AotCache
    ) throws -> [AotInstructionMapSubmapEntry]? {
        guard 0 <= index,
              index < map.header.entryCount else {
            return nil
        }
        let entry = map.entries(in: cache)[index]
        return try AotInstructionMapSubmapDecoder.decode(
            submap: self,
            header: map.header,
            entry: entry,
            readByte: { try cache.fileHandle.read(offset: $0) }
        )
    }

    public func entries(
        for map: AotInstructionMap,
        in machO: MachOFile
    ) throws -> [AotInstructionMapSubmapEntry]? {
        guard 0 <= index,
              index < map.header.entryCount else {
            return nil
        }
        let entry = map.entries(in: machO)[index]
        return try AotInstructionMapSubmapDecoder.decode(
            submap: self,
            header: map.header,
            entry: entry,
            readByte: { try machO.fileHandle.read(offset: $0) }
        )
    }
}
