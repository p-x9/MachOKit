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
    public func compactEntries(in machO: MachOFile) -> DataSequence<AotBranchDataIndexEntryCompact>? {
        guard header.kind == 1 else { return nil }
        return machO.fileHandle.readDataSequence(
            offset: UInt64(offset + AotBranchDataHeader.layoutSize),
            numberOfElements: numericCast(header.entry_count)
        )
    }

    public func entries(in machO: MachOFile) -> DataSequence<AotBranchDataIndexEntry>? {
        guard header.kind == 2 else { return nil }
        return machO.fileHandle.readDataSequence(
            offset: UInt64(offset + AotBranchDataHeader.layoutSize),
            numberOfElements: numericCast(header.entry_count)
        )
    }

    public func extendedEntries(in machO: MachOFile) -> DataSequence<AotBranchDataIndexEntryExtended>? {
        guard header.kind == 3 else { return nil }
        return machO.fileHandle.readDataSequence(
            offset: UInt64(offset + AotBranchDataHeader.layoutSize),
            numberOfElements: numericCast(header.entry_count)
        )
    }
}

extension AotBranchData {
    public func payloadRecords(
        for entry: AotBranchDataIndexEntryCompact,
        in cache: AotCache
    ) -> [AotBranchDataPayloadRecord]? {
        guard header.kind == 1 else { return nil }
        return _payloadRecords(
            for: entry,
            readData: { try? cache.fileHandle.readData(offset: $0, length: $1) }
        )
    }

    public func payloadRecords(
        for entry: AotBranchDataIndexEntry,
        in cache: AotCache
    ) -> [AotBranchDataPayloadRecord]? {
        guard header.kind == 2 else { return nil }
        return _payloadRecords(
            for: entry,
            readData: { try? cache.fileHandle.readData(offset: $0, length: $1) }
        )
    }

    public func payloadRecords(
        for entry: AotBranchDataIndexEntryExtended,
        in cache: AotCache
    ) -> [AotBranchDataPayloadRecordExtended]? {
        guard header.kind == 3 else { return nil }
        return _payloadRecordsExtended(
            for: entry,
            readData: { try? cache.fileHandle.readData(offset: $0, length: $1) }
        )
    }
}

extension AotBranchData {
    public func payloadRecords(
        for entry: AotBranchDataIndexEntryCompact,
        in machO: MachOFile
    ) -> [AotBranchDataPayloadRecord]? {
        guard header.kind == 1 else { return nil }
        return _payloadRecords(
            for: entry,
            readData: { try? machO.fileHandle.readData(offset: $0, length: $1) }
        )
    }

    public func payloadRecords(
        for entry: AotBranchDataIndexEntry,
        in machO: MachOFile
    ) -> [AotBranchDataPayloadRecord]? {
        guard header.kind == 2 else { return nil }
        return _payloadRecords(
            for: entry,
            readData: { try? machO.fileHandle.readData(offset: $0, length: $1) }
        )
    }

    public func payloadRecords(
        for entry: AotBranchDataIndexEntryExtended,
        in machO: MachOFile
    ) -> [AotBranchDataPayloadRecordExtended]? {
        guard header.kind == 3 else { return nil }
        return _payloadRecordsExtended(
            for: entry,
            readData: { try? machO.fileHandle.readData(offset: $0, length: $1) }
        )
    }
}

extension AotBranchData {
    public func payloadLocations(
        for entry: AotBranchDataIndexEntryCompact,
        in cache: AotCache
    ) -> [AotBranchDataPayloadLocation]? {
        payloadRecords(for: entry, in: cache)?
            .map { .init(record: $0, entry: entry) }
    }

    public func payloadLocations(
        for entry: AotBranchDataIndexEntry,
        in cache: AotCache
    ) -> [AotBranchDataPayloadLocation]? {
        payloadRecords(for: entry, in: cache)?
            .map { .init(record: $0, entry: entry) }
    }

    public func payloadLocations(
        for entry: AotBranchDataIndexEntryExtended,
        in cache: AotCache
    ) -> [AotBranchDataPayloadLocation]? {
        payloadRecords(for: entry, in: cache)?
            .map { .init(record: $0, entry: entry) }
    }
}

extension AotBranchData {
    public func payloadLocations(
        for entry: AotBranchDataIndexEntryCompact,
        in machO: MachOFile
    ) -> [AotBranchDataPayloadLocation]? {
        payloadRecords(for: entry, in: machO)?
            .map { .init(record: $0, entry: entry) }
    }

    public func payloadLocations(
        for entry: AotBranchDataIndexEntry,
        in machO: MachOFile
    ) -> [AotBranchDataPayloadLocation]? {
        payloadRecords(for: entry, in: machO)?
            .map { .init(record: $0, entry: entry) }
    }

    public func payloadLocations(
        for entry: AotBranchDataIndexEntryExtended,
        in machO: MachOFile
    ) -> [AotBranchDataPayloadLocation]? {
        payloadRecords(for: entry, in: machO)?
            .map { .init(record: $0, entry: entry) }
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

    private func _payloadData<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        readData: (Int, Int) -> Data?
    ) -> Data? {
        guard let payloadStartOffset,
              let payloadRecordSize,
              entry.payloadRecordOffset >= 0,
              entry.payloadRecordCount >= 0 else {
            return nil
        }

        let payloadOffset = payloadStartOffset + entry.payloadRecordOffset * payloadRecordSize
        let payloadLength = entry.payloadRecordCount * payloadRecordSize
        guard payloadOffset + payloadLength <= offset + header.blockSize else {
            return nil
        }
        guard payloadLength > 0 else {
            return Data()
        }

        return readData(
            payloadOffset,
            payloadLength
        )
    }

    private func _payloadRecords<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        readData: (Int, Int) -> Data?
    ) -> [AotBranchDataPayloadRecord]? {
        guard let data = _payloadData(
            for: entry,
            readData: readData
        ) else {
            return nil
        }

        return _payloadRecords(for: entry, data: data)
    }

    private func _payloadRecords<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        data: Data
    ) -> [AotBranchDataPayloadRecord]? {
        guard header.kind == 1 || header.kind == 2,
              data.count == entry.payloadRecordCount * AotBranchDataPayloadRecord.layoutSize else {
            return nil
        }

        return (0..<entry.payloadRecordCount).compactMap { index in
            let offset = index * AotBranchDataPayloadRecord.layoutSize
            return AotBranchDataPayloadRecord(
                layout: .init(
                    x86_code_bucket_offset: data[offset],
                    arm_code_bucket_instruction_index: data[offset + 1]
                )
            )
        }
    }

    private func _payloadRecordsExtended<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        readData: (Int, Int) -> Data?
    ) -> [AotBranchDataPayloadRecordExtended]? {
        guard let data = _payloadData(
            for: entry,
            readData: readData
        ) else {
            return nil
        }

        return _payloadRecordsExtended(for: entry, data: data)
    }

    private func _payloadRecordsExtended<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        data: Data
    ) -> [AotBranchDataPayloadRecordExtended]? {
        guard header.kind == 3,
              data.count == entry.payloadRecordCount * AotBranchDataPayloadRecordExtended.layoutSize else {
            return nil
        }

        return (0..<entry.payloadRecordCount).compactMap { index in
            let offset = index * AotBranchDataPayloadRecordExtended.layoutSize
            return AotBranchDataPayloadRecordExtended(
                layout: .init(
                    x86_code_bucket_offset: UInt16(data[offset])
                        | UInt16(data[offset + 1]) << 8,
                    arm_code_bucket_instruction_index: UInt16(data[offset + 2])
                        | UInt16(data[offset + 3]) << 8
                )
            )
        }
    }
}
