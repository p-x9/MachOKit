//
//  AotInstructionMap.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/17
//  
//

import Foundation
import MachOKitC

public struct AotInstructionMap: Sendable {
    public let header: AotInstructionMapHeader
    public let offset: Int
}

extension AotInstructionMap {
    public func entries(in cache: AotCache) -> DataSequence<AotInstructionMapIndexEntry> {
        cache.fileHandle.readDataSequence(
            offset: UInt64(offset + AotInstructionMapHeader.layoutSize),
            numberOfElements: numericCast(header.entry_count)
        )
    }

    public func entries(in machO: MachOFile) -> DataSequence<AotInstructionMapIndexEntry> {
        machO.fileHandle.readDataSequence(
            offset: UInt64(offset + AotInstructionMapHeader.layoutSize),
            numberOfElements: numericCast(header.entry_count)
        )
    }
}

// MARK: - Submap Size

extension AotInstructionMap {
    public func submapSizes(in cache: AotCache) -> [Int]? {
        _submapSizes(entries: Array(entries(in: cache)))
    }

    public func submapSizes(in machO: MachOFile) -> [Int]? {
        _submapSizes(entries: Array(entries(in: machO)))
    }

    public func submapSize(
        at index: Int,
        in cache: AotCache
    ) -> Int? {
        _submapSize(
            at: index,
            entries: Array(entries(in: cache))
        )
    }

    public func submapSize(
        for entry: AotInstructionMapIndexEntry,
        in cache: AotCache
    ) -> Int? {
        _submapSize(
            for: entry,
            entries: Array(entries(in: cache))
        )
    }

    public func submapSize(
        at index: Int,
        in machO: MachOFile
    ) -> Int? {
        _submapSize(
            at: index,
            entries: Array(entries(in: machO))
        )
    }

    public func submapSize(
        for entry: AotInstructionMapIndexEntry,
        in machO: MachOFile
    ) -> Int? {
        _submapSize(
            for: entry,
            entries: Array(entries(in: machO))
        )
    }
}

// MARK: - Submap

extension AotInstructionMap {
    public func submaps(in cache: AotCache) -> [AotInstructionMapSubmap]? {
        _submaps(
            entries: Array(entries(in: cache))
        )
    }

    public func submaps(in machO: MachOFile) -> [AotInstructionMapSubmap]? {
        _submaps(
            entries: Array(entries(in: machO))
        )
    }

    public func submap(
        at index: Int,
        in cache: AotCache
    ) -> AotInstructionMapSubmap? {
        _submap(
            at: index,
            entries: Array(entries(in: cache))
        )
    }

    public func submap(
        for entry: AotInstructionMapIndexEntry,
        in cache: AotCache
    ) -> AotInstructionMapSubmap? {
        let entries = Array(entries(in: cache))
        guard let index = entries.firstIndex(
            where: { $0 == entry }
        ) else { return nil }
        return _submap(
            at: index,
            entries: entries
        )
    }

    public func submap(
        at index: Int,
        in machO: MachOFile
    ) -> AotInstructionMapSubmap? {
        _submap(
            at: index,
            entries: Array(entries(in: machO))
        )
    }

    public func submap(
        for entry: AotInstructionMapIndexEntry,
        in machO: MachOFile
    ) -> AotInstructionMapSubmap? {
        let entries = Array(entries(in: machO))
        guard let index = entries.firstIndex(
            where: { $0 == entry }
        ) else { return nil }
        return _submap(
            at: index,
            entries: entries
        )
    }
}

// MARK: Private: submap size

extension AotInstructionMap {
    private func _submapSizes(
        entries: [AotInstructionMapIndexEntry]
    ) -> [Int]? {
        guard !entries.isEmpty else { return [] }
        var sizes: [Int] = []
        sizes.reserveCapacity(entries.count)

        for index in entries.indices {
            guard let size = _submapSize(
                at: index,
                entries: entries
            ) else {
                return nil
            }
            sizes.append(size)
        }

        return sizes
    }

    private func _submapSize(
        at index: Int,
        entries: [AotInstructionMapIndexEntry]
    ) -> Int? {
        _submapBounds(at: index, entries: entries)?.size
    }

    private func _submapSize(
        for entry: AotInstructionMapIndexEntry,
        entries: [AotInstructionMapIndexEntry]
    ) -> Int? {
        guard let index = entries.firstIndex(
            where: { $0 == entry }
        ) else { return nil }
        return _submapSize(at: index, entries: entries)
    }
}

// MARK: Private: submap

extension AotInstructionMap {
    private func _submaps(
        entries: [AotInstructionMapIndexEntry]
    ) -> [AotInstructionMapSubmap]? {
        guard !entries.isEmpty else { return [] }
        var submaps: [AotInstructionMapSubmap] = []
        submaps.reserveCapacity(entries.count)

        for index in entries.indices {
            guard let submap = _submap(
                at: index,
                entries: entries
            ) else {
                return nil
            }
            submaps.append(submap)
        }

        return submaps
    }

    private func _submap(
        at index: Int,
        entries: [AotInstructionMapIndexEntry]
    ) -> AotInstructionMapSubmap? {
        guard let bounds = _submapBounds(at: index, entries: entries) else {
            return nil
        }

        return .init(
            index: index,
            offset: bounds.offset
        )
    }

    private func _submapBounds(
        at index: Int,
        entries: [AotInstructionMapIndexEntry]
    ) -> (offset: Int, size: Int)? {
        guard index >= 0, index < entries.count else { return nil }

        let entry = entries[index]
        let submapStart = header.firstSubmapOffset + entry.submapOffset
        let submapEnd: Int
        if index + 1 < entries.count {
            let nextEntry = entries[index + 1]
            guard nextEntry.submapOffset >= entry.submapOffset else {
                return nil
            }
            submapEnd = header.firstSubmapOffset + nextEntry.submapOffset
        } else {
            submapEnd = header.mapSize
        }

        guard submapStart >= header.firstSubmapOffset,
              submapStart <= submapEnd,
              submapEnd <= header.mapSize else {
            return nil
        }

        return (
            offset: offset + submapStart,
            size: submapEnd - submapStart
        )
    }
}
