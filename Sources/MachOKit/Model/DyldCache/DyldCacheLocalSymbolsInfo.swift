//
//  DyldCacheLocalSymbolsInfo.swift
//
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheLocalSymbolsInfo: LayoutWrapper {
    public typealias Layout = dyld_cache_local_symbols_info

    public var layout: Layout
}

extension DyldCacheLocalSymbolsInfo {
    /// Sequence of 64-bit architecture symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols64(in cache: DyldCache) -> MachOFile.Symbols64? {
        guard cache.cpu.is64Bit else { return nil }

        let stringData = cache.fileHandle.readData(
            offset: cache.header.localSymbolsOffset + numericCast(layout.stringsOffset),
            size: numericCast(layout.stringsSize)
        )

        let symbolData = cache.fileHandle.readData(
            offset: cache.header.localSymbolsOffset + numericCast(layout.nlistOffset),
            size: numericCast(Nlist64.layoutSize) * numericCast(layout.nlistCount)
        )

        return MachOFile.Symbols64(
            symtab: nil,
            stringData: stringData,
            symbolsData: symbolData,
            numberOfSymbols: numericCast(layout.nlistCount)
        )
    }

    /// Sequence of 32-bit architecture symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols32(in cache: DyldCache) -> MachOFile.Symbols? {
        guard !cache.cpu.is64Bit else { return nil }

        let stringData = cache.fileHandle.readData(
            offset: cache.header.localSymbolsOffset + numericCast(layout.stringsOffset),
            size: numericCast(layout.stringsSize)
        )

        let symbolData = cache.fileHandle.readData(
            offset: cache.header.localSymbolsOffset + numericCast(layout.nlistOffset),
            size: numericCast(Nlist.layoutSize) * numericCast(layout.nlistCount)
        )

        return MachOFile.Symbols(
            symtab: nil,
            stringData: stringData,
            symbolsData: symbolData,
            numberOfSymbols: numericCast(layout.nlistCount)
        )
    }

    /// Sequence of symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols(in cache: DyldCache) -> AnyRandomAccessCollection<MachOFile.Symbol> {
        if let symbols64 = symbols64(in: cache) {
            return AnyRandomAccessCollection(symbols64)
        } else if let symbols32 = symbols32(in: cache) {
            return AnyRandomAccessCollection(symbols32)
        } else {
            return AnyRandomAccessCollection([])
        }
    }
}

extension DyldCacheLocalSymbolsInfo {
    /// Sequence of 64-bit architecture symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols64(in cache: DyldCacheLoaded) -> MachOImage.Symbols64? {
        guard cache.cpu.is64Bit else { return nil }

        return .init(
            stringBase: cache.ptr
                .advanced(by: numericCast(cache.header.localSymbolsOffset))
                .advanced(by: numericCast(layout.stringsOffset))
                .assumingMemoryBound(to: CChar.self),
            addressStart: 0, // FIXME: Fix
            symbols: cache.ptr
                .advanced(by: numericCast(cache.header.localSymbolsOffset))
                .advanced(by: numericCast(layout.nlistOffset))
                .assumingMemoryBound(to: nlist_64.self),
            numberOfSymbols: numericCast(layout.nlistCount)
        )
    }

    /// Sequence of 32-bit architecture symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols32(in cache: DyldCacheLoaded) -> MachOImage.Symbols? {
        guard !cache.cpu.is64Bit else { return nil }

        return .init(
            stringBase: cache.ptr
                .advanced(by: numericCast(cache.header.localSymbolsOffset))
                .advanced(by: numericCast(layout.stringsOffset))
                .assumingMemoryBound(to: CChar.self),
            addressStart: 0, // FIXME: Fix
            symbols: cache.ptr
                .advanced(by: numericCast(cache.header.localSymbolsOffset))
                .advanced(by: numericCast(layout.nlistOffset))
                .assumingMemoryBound(to: nlist.self),
            numberOfSymbols: numericCast(layout.nlistCount)
        )
    }

    /// Sequence of symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols(in cache: DyldCacheLoaded) -> AnyRandomAccessCollection<MachOImage.Symbol> {
        if let symbols64 = symbols64(in: cache) {
            return AnyRandomAccessCollection(symbols64)
        } else if let symbols32 = symbols32(in: cache) {
            return AnyRandomAccessCollection(symbols32)
        } else {
            return AnyRandomAccessCollection([])
        }
    }
}

extension DyldCacheLocalSymbolsInfo {
    /// Sequence of 64-bit architecture symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries64(
        in cache: DyldCache
    ) -> DataSequence<DyldCacheLocalSymbolsEntry64>? {
        guard cache.cpu.is64Bit else { return nil }
        let offset: UInt64 = cache.header.localSymbolsOffset + numericCast(layout.entriesOffset)

        return cache.fileHandle.readDataSequence(
            offset: offset,
            numberOfElements: numericCast(layout.entriesCount)
        )
    }

    /// Sequence of 32-bit architecture symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries32(
        in cache: DyldCache
    ) -> DataSequence<DyldCacheLocalSymbolsEntry>? {
        guard !cache.cpu.is64Bit else { return nil }

        let offset: UInt64 = cache.header.localSymbolsOffset + numericCast(layout.entriesOffset)

        return cache.fileHandle.readDataSequence(
            offset: offset,
            numberOfElements: numericCast(layout.entriesCount)
        )
    }

    /// Sequence of symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries(
        in cache: DyldCache
    ) -> AnyRandomAccessCollection<any DyldCacheLocalSymbolsEntryProtocol> {
        if let entries = entries64(in: cache) {
            return AnyRandomAccessCollection(
                entries
                    .lazy
                    .map { $0 as (any DyldCacheLocalSymbolsEntryProtocol) }
            )
        } else if let entries = entries32(in: cache) {
            return AnyRandomAccessCollection(
                entries
                    .lazy
                    .map { $0 as (any DyldCacheLocalSymbolsEntryProtocol) }
            )
        } else {
            return AnyRandomAccessCollection([])
        }
    }
}

extension DyldCacheLocalSymbolsInfo {
    /// Sequence of 64-bit architecture symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries64(
        in cache: DyldCacheLoaded
    ) -> MemorySequence<DyldCacheLocalSymbolsEntry64>? {
        guard cache.cpu.is64Bit else { return nil }
        let offset: UInt64 = cache.header.localSymbolsOffset + numericCast(layout.entriesOffset)

        return .init(
            basePointer: cache.ptr
                .advanced(by: numericCast(offset))
                .autoBoundPointee(),
            numberOfElements: numericCast(layout.entriesCount)
        )
    }

    /// Sequence of 32-bit architecture symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries32(
        in cache: DyldCacheLoaded
    ) -> MemorySequence<DyldCacheLocalSymbolsEntry>? {
        guard !cache.cpu.is64Bit else { return nil }

        let offset: UInt64 = cache.header.localSymbolsOffset + numericCast(layout.entriesOffset)

        return .init(
            basePointer: cache.ptr
                .advanced(by: numericCast(offset))
                .autoBoundPointee(),
            numberOfElements: numericCast(layout.entriesCount)
        )
    }

    /// Sequence of symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries(
        in cache: DyldCacheLoaded
    ) -> AnyRandomAccessCollection<any DyldCacheLocalSymbolsEntryProtocol> {
        if let entries = entries64(in: cache) {
            return AnyRandomAccessCollection(
                entries
                    .lazy
                    .map { $0 as (any DyldCacheLocalSymbolsEntryProtocol) }
            )
        } else if let entries = entries32(in: cache) {
            return AnyRandomAccessCollection(
                entries
                    .lazy
                    .map { $0 as (any DyldCacheLocalSymbolsEntryProtocol) }
            )
        } else {
            return AnyRandomAccessCollection([])
        }
    }
}
