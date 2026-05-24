//
//  AotBranchData.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/18
//  
//

import Foundation
import MachOKitC

public struct AotBranchData: Sendable {
    public let header: AotBranchDataHeader
    public let offset: Int
}

extension AotBranchData {
    public var payloadRecordSize: Int? {
        switch header.kind {
        case 1, 2: AotBranchDataPayloadRecord.layoutSize
        case 3: AotBranchDataPayloadRecordExtended.layoutSize
        default: nil
        }
    }
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

extension AotBranchData {
    public func payloadRecords(
        for entry: AotBranchDataIndexEntryCompact,
        in cache: AotCache
    ) -> [AotBranchDataPayloadLocation]? {
        guard let entries = compactEntries(in: cache) else { return nil }
        return _payloadRecords(
            for: entry,
            entries: Array(entries),
            readData: { try? cache.fileHandle.readData(offset: $0, length: $1) }
        )
    }

    public func payloadRecords(
        for entry: AotBranchDataIndexEntry,
        in cache: AotCache
    ) -> [AotBranchDataPayloadLocation]? {
        guard let entries = entries(in: cache) else { return nil }
        return _payloadRecords(
            for: entry,
            entries: Array(entries),
            readData: { try? cache.fileHandle.readData(offset: $0, length: $1) }
        )
    }

    public func payloadRecords(
        for entry: AotBranchDataIndexEntryExtended,
        in cache: AotCache
    ) -> [AotBranchDataPayloadLocation]? {
        guard let entries = extendedEntries(in: cache) else { return nil }
        return _payloadRecords(
            for: entry,
            entries: Array(entries),
            readData: { try? cache.fileHandle.readData(offset: $0, length: $1) }
        )
    }
}

extension AotBranchData {
    private var entrySize: Int? {
        switch header.kind {
        case 1: AotBranchDataIndexEntryCompact.layoutSize
        case 2: AotBranchDataIndexEntry.layoutSize
        case 3: AotBranchDataIndexEntryExtended.layoutSize
        default: nil
        }
    }

    private var payloadStartOffset: Int? {
        guard let entrySize else { return nil }
        return offset + AotBranchDataHeader.layoutSize + entrySize * numericCast(header.entry_count)
    }

    private func payloadRecordCount<Entry: AotBranchDataPayloadEntry>(
        entries: [Entry]
    ) -> Int? {
        entries.map { $0.payloadRecordOffset + $0.payloadRecordCount }.max()
    }

    private func _payloadData<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        entries: [Entry],
        readData: (Int, Int) -> Data?
    ) -> Data? {
        guard let payloadStartOffset,
              let payloadRecordSize,
              let payloadRecordCount = payloadRecordCount(entries: entries),
              entry.payloadRecordOffset + entry.payloadRecordCount <= payloadRecordCount else {
            return nil
        }

        return readData(
            payloadStartOffset + entry.payloadRecordOffset * payloadRecordSize,
            entry.payloadRecordCount * payloadRecordSize
        )
    }

    private func _payloadRecords<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        entries: [Entry],
        readData: (Int, Int) -> Data?
    ) -> [AotBranchDataPayloadLocation]? {
        guard let data = _payloadData(
            for: entry,
            entries: entries,
            readData: readData
        ) else {
            return nil
        }

        return _payloadRecords(for: entry, data: data)
    }

    private func _payloadRecords<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        data: Data
    ) -> [AotBranchDataPayloadLocation]? {
        guard let payloadRecordSize,
              data.count == entry.payloadRecordCount * payloadRecordSize else {
            return nil
        }

        return (0..<entry.payloadRecordCount).compactMap { index in
            let offset = index * payloadRecordSize
            let x86BucketRelativeOffset: Int
            let armBucketRelativeInstructionIndex: Int

            switch header.kind {
            case 1, 2:
                x86BucketRelativeOffset = numericCast(data[offset])
                armBucketRelativeInstructionIndex = numericCast(data[offset + 1])
            case 3:
                x86BucketRelativeOffset = Int(data[offset])
                    | Int(data[offset + 1]) << 8
                armBucketRelativeInstructionIndex = Int(data[offset + 2])
                    | Int(data[offset + 3]) << 8
            default:
                return nil
            }

            return AotBranchDataPayloadLocation(
                x86CodeBucketRelativeOffset: x86BucketRelativeOffset,
                armCodeBucketRelativeInstructionIndex: armBucketRelativeInstructionIndex,
                x86CodeOffset: entry.x86CodeBucketOffset + x86BucketRelativeOffset,
                armCodeOffset: entry.armCodeBucketOffset + armBucketRelativeInstructionIndex * 4
            )
        }
    }
}
