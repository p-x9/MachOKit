//
//  DyldCacheLocalSymbolsInfo.swift
//
//
//  Created by p-x9 on 2024/01/15.
//
//

import Foundation

public struct DyldCacheLocalSymbolsInfo: LayoutWrapper, Sendable {
    public typealias Layout = dyld_cache_local_symbols_info

    public var layout: Layout
    public var offset: Int // file offset from cache file starts
}

extension DyldCacheLocalSymbolsInfo {
    /// Sequence of 64-bit architecture symbols
    ///
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols64(in cache: DyldCache) -> MachOFile.Symbols64? {
        guard cache.cpu.is64Bit else { return nil }

        let stringData = try! cache.fileHandle.fileSlice(
            offset: Int(cache.header.localSymbolsOffset) + numericCast(layout.stringsOffset),
            length: numericCast(layout.stringsSize)
        )

        let symbolData = try! cache.fileHandle.fileSlice(
            offset: Int(cache.header.localSymbolsOffset) + numericCast(layout.nlistOffset),
            length: numericCast(Nlist64.layoutSize) * numericCast(layout.nlistCount)
        )

        return MachOFile.Symbols64(
            symtab: nil,
            stringsSlice: stringData,
            symbolsSlice: symbolData,
            numberOfSymbols: numericCast(layout.nlistCount),
            isSwapped: false
        )
    }

    /// Sequence of 32-bit architecture symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols32(in cache: DyldCache) -> MachOFile.Symbols? {
        guard !cache.cpu.is64Bit else { return nil }

        let stringData = try! cache.fileHandle.fileSlice(
            offset: Int(cache.header.localSymbolsOffset) + numericCast(layout.stringsOffset),
            length: numericCast(layout.stringsSize)
        )

        let symbolData = try! cache.fileHandle.fileSlice(
            offset: Int(cache.header.localSymbolsOffset) + numericCast(layout.nlistOffset),
            length: numericCast(Nlist.layoutSize) * numericCast(layout.nlistCount)
        )

        return MachOFile.Symbols(
            symtab: nil,
            stringsSlice: stringData,
            symbolsSlice: symbolData,
            numberOfSymbols: numericCast(layout.nlistCount),
            isSwapped: false
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
    public func symbols64(in cache: FullDyldCache) -> MachOFile.Symbols64? {
        guard let cache = cache.cache(
            forOffset: cache.header.localSymbolsOffset + numericCast(layout.stringsOffset)
        ) else {
            return nil
        }
        return symbols64(in: cache)
    }

    /// Sequence of 32-bit architecture symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols32(in cache: FullDyldCache) -> MachOFile.Symbols? {
        guard let cache = cache.cache(
            forOffset: cache.header.localSymbolsOffset + numericCast(layout.stringsOffset)
        ) else {
            return nil
        }
        return symbols32(in: cache)
    }

    /// Sequence of symbols
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of symbols
    public func symbols(in cache: FullDyldCache) -> AnyRandomAccessCollection<MachOFile.Symbol> {
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
    /// Determines whether the local symbols entry format is 64-bit.
    ///
    /// This checks whether entries use the 64-bit layout based on the architecture
    /// of the provided cache and the layout boundaries of the symbol entries.
    ///
    /// - Warning: In recent dyld caches, even those intended for 32-bit architectures utilize the 64-bit entry format.
    ///
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/637911768f664e38e7e50b4fbf17e303e14fdc01/framework/LegacyAPIShims.mm#L412)
    ///
    /// - Parameter cache: The cache used to evaluate the entry format.
    /// - Returns: `true` if the entries are in 64-bit format, otherwise `false`.
    public func is64BitEntryFormat(in cache: any DyldCacheRepresentable) -> Bool {
        if cache.cpu.is64Bit { return true }
        // WORKAROUND: 
        let entriesSize = numericCast(layout.entriesCount) * DyldCacheLocalSymbolsEntry64.layoutSize
        return layout.nlistOffset >= layout.entriesOffset + numericCast(entriesSize)
    }
}

extension DyldCacheLocalSymbolsInfo {
    /// Sequence of 64-bit architecture symbols entries
    ///
    /// - Warning: In recent dyld caches, even those intended for 32-bit architectures utilize the 64-bit entry format.
    ///
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries64(
        in cache: DyldCache
    ) -> DataSequence<DyldCacheLocalSymbolsEntry64>? {
        _entries64(in: cache)
    }

    /// Sequence of 32-bit architecture symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries32(
        in cache: DyldCache
    ) -> DataSequence<DyldCacheLocalSymbolsEntry>? {
        _entries32(in: cache)
    }

    /// Sequence of symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries(
        in cache: DyldCache
    ) -> AnyRandomAccessCollection<any DyldCacheLocalSymbolsEntryProtocol> {
        _entries(in: cache)
    }
}

extension DyldCacheLocalSymbolsInfo {
    /// Sequence of 64-bit architecture symbols entries
    ///
    /// - Warning: In recent dyld caches, even those intended for 32-bit architectures utilize the 64-bit entry format.
    ///
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries64(
        in cache: FullDyldCache
    ) -> DataSequence<DyldCacheLocalSymbolsEntry64>? {
        _entries64(in: cache)
    }

    /// Sequence of 32-bit architecture symbols entries
    ///
    /// - Warning: In recent dyld caches, even those intended for 32-bit architectures utilize the 64-bit entry format.
    ///
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries32(
        in cache: FullDyldCache
    ) -> DataSequence<DyldCacheLocalSymbolsEntry>? {
        _entries32(in: cache)
    }

    /// Sequence of symbols entries
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries(
        in cache: FullDyldCache
    ) -> AnyRandomAccessCollection<any DyldCacheLocalSymbolsEntryProtocol> {
        _entries(in: cache)
    }
}

extension DyldCacheLocalSymbolsInfo {
    internal func _entries64<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DataSequence<DyldCacheLocalSymbolsEntry64>? {
        // On new caches, the dylibOffset is 64-bits, and is a VM offset
        guard is64BitEntryFormat(in: cache) else { return nil }
        let offset: UInt64 = cache.header.localSymbolsOffset + numericCast(layout.entriesOffset)

        return cache.fileHandle.readDataSequence(
            offset: offset,
            numberOfElements: numericCast(layout.entriesCount)
        )
    }

    internal func _entries32<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DataSequence<DyldCacheLocalSymbolsEntry>? {
        guard !is64BitEntryFormat(in: cache) else { return nil }

        let offset: UInt64 = cache.header.localSymbolsOffset + numericCast(layout.entriesOffset)

        return cache.fileHandle.readDataSequence(
            offset: offset,
            numberOfElements: numericCast(layout.entriesCount)
        )
    }

    internal func _entries<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> AnyRandomAccessCollection<any DyldCacheLocalSymbolsEntryProtocol> {
        if let entries = _entries64(in: cache) {
            return AnyRandomAccessCollection(
                entries
                    .lazy
                    .map { $0 }
            )
        } else if let entries = _entries32(in: cache) {
            return AnyRandomAccessCollection(
                entries
                    .lazy
                    .map { $0 }
            )
        } else {
            return AnyRandomAccessCollection([])
        }
    }
}

extension DyldCacheLocalSymbolsInfo {
    /// Sequence of 64-bit architecture symbols entries
    ///
    /// - Warning: In recent dyld caches, even those intended for 32-bit architectures utilize the 64-bit entry format.
    ///
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries64(
        in cache: DyldCacheLoaded
    ) -> MemorySequence<DyldCacheLocalSymbolsEntry64>? {
        guard is64BitEntryFormat(in: cache) else { return nil }
        let offset: UInt64 = cache.header.localSymbolsOffset + numericCast(layout.entriesOffset)

        return .init(
            basePointer: cache.ptr
                .advanced(by: numericCast(offset))
                .autoBoundPointee(),
            numberOfElements: numericCast(layout.entriesCount)
        )
    }

    /// Sequence of 32-bit architecture symbols entries
    ///
    /// - Warning: In recent dyld caches, even those intended for 32-bit architectures utilize the 64-bit entry format.
    ///
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: Sequence of  symbols entries
    public func entries32(
        in cache: DyldCacheLoaded
    ) -> MemorySequence<DyldCacheLocalSymbolsEntry>? {
        guard !is64BitEntryFormat(in: cache) else { return nil }

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

extension DyldCacheLocalSymbolsInfo {
    /// Returns the 64-bit local symbols entry corresponding to the given Mach-O file.
    ///
    /// This searches the local symbols entries for one whose `dylibOffset` matches
    /// the Mach-O file's text segment offset within the dyld cache.
    ///
    /// - Parameters:
    ///   - machO: The Mach-O file whose entry should be resolved.
    ///   - cache: The dyld cache containing the symbols info.
    /// - Returns: The matching 64-bit entry, or `nil` if no match exists.
    public func entry64(
        for machO: MachOFile,
        in cache: DyldCache
    ) -> DyldCacheLocalSymbolsEntry64? {
        guard let dylibOffset = dylibOffset(of: machO, in: cache) else { return nil }
        return entries64(in: cache)?.first(
            where: {
                $0.dylibOffset == dylibOffset
            }
        )
    }

    /// Returns the 32-bit local symbols entry corresponding to the given Mach-O file.
    ///
    /// This searches the 32-bit entry sequence for an entry whose `dylibOffset`
    /// matches the text segment offset of the Mach-O file within the dyld cache.
    ///
    /// - Parameters:
    ///   - machO: The Mach-O file whose entry should be resolved.
    ///   - cache: The dyld cache containing the symbols info.
    /// - Returns: The matching 32-bit entry, or `nil` if no match exists.
    public func entry32(
        for machO: MachOFile,
        in cache: DyldCache
    ) -> DyldCacheLocalSymbolsEntry? {
        guard let dylibOffset = dylibOffset(of: machO, in: cache) else { return nil }
        return entries32(in: cache)?.first(
            where: {
                $0.dylibOffset == dylibOffset
            }
        )
    }

    /// Returns the local symbols entry corresponding to the given Mach-O file.
    ///
    /// This resolves the Mach-O file's text segment offset and finds the first entry
    /// whose `dylibOffset` matches it, regardless of entry format.
    ///
    /// - Parameters:
    ///   - machO: The Mach-O file whose entry should be resolved.
    ///   - cache: The dyld cache containing the symbols info.
    /// - Returns: The matching entry, or `nil` if no match exists.
    public func entry(
        for machO: MachOFile,
        in cache: DyldCache
    ) -> (any DyldCacheLocalSymbolsEntryProtocol)? {
        guard let dylibOffset = dylibOffset(of: machO, in: cache) else { return nil }
        return entries(in: cache).first(
            where: {
                $0.dylibOffset == dylibOffset
            }
        )
    }
}

extension DyldCacheLocalSymbolsInfo {
    /// Returns the 64-bit local symbols entry corresponding to the given Mach-O file
    /// within a full dyld cache.
    ///
    /// This searches the 64-bit entry sequence for one whose `dylibOffset` matches
    /// the Mach-O file's text segment offset.
    ///
    /// - Parameters:
    ///   - machO: The Mach-O file whose entry should be resolved.
    ///   - cache: The full dyld cache containing the symbols info.
    /// - Returns: The matching 64-bit entry, or `nil` if no match exists.
    public func entry64(
        for machO: MachOFile,
        in cache: FullDyldCache
    ) -> DyldCacheLocalSymbolsEntry64? {
        guard let dylibOffset = dylibOffset(of: machO, in: cache) else { return nil }
        return entries64(in: cache)?.first(
            where: {
                $0.dylibOffset == dylibOffset
            }
        )
    }

    /// Returns the 32-bit local symbols entry corresponding to the given Mach-O file
    /// within a full dyld cache.
    ///
    /// This searches the 32-bit entry sequence for an entry whose `dylibOffset`
    /// matches the Mach-O file's text segment offset.
    ///
    /// - Parameters:
    ///   - machO: The Mach-O file whose entry should be resolved.
    ///   - cache: The full dyld cache containing the symbols info.
    /// - Returns: The matching 32-bit entry, or `nil` if no match exists.
    public func entry32(
        for machO: MachOFile,
        in cache: FullDyldCache
    ) -> DyldCacheLocalSymbolsEntry? {
        guard let dylibOffset = dylibOffset(of: machO, in: cache) else { return nil }
        return entries32(in: cache)?.first(
            where: {
                $0.dylibOffset == dylibOffset
            }
        )
    }

    /// Returns the local symbols entry corresponding to the given Mach-O file
    /// within a full dyld cache.
    ///
    /// This resolves the Mach-O file's text segment offset and finds the first entry
    /// whose `dylibOffset` matches it, selecting the correct entry format automatically.
    ///
    /// - Parameters:
    ///   - machO: The Mach-O file whose entry should be resolved.
    ///   - cache: The full dyld cache containing the symbols info.
    /// - Returns: The matching entry, or `nil` if no match exists.
    public func entry(
        for machO: MachOFile,
        in cache: FullDyldCache
    ) -> (any DyldCacheLocalSymbolsEntryProtocol)? {
        guard let dylibOffset = dylibOffset(of: machO, in: cache) else { return nil }
        return entries(in: cache).first(
            where: {
                $0.dylibOffset == dylibOffset
            }
        )
    }
}

extension DyldCacheLocalSymbolsInfo {
    func dylibOffset(of machO: MachOFile, in cache: DyldCache) -> UInt64? {
        guard var offset = machO.textOffset(in: cache) else { return nil }
        if !is64BitEntryFormat(in: cache) {
            guard let _offset = machO.loadCommands.text?.fileOffset else { return nil }
            offset = UInt64(_offset)
        }
        return offset
    }

    func dylibOffset(of machO: MachOFile, in cache: FullDyldCache) -> UInt64? {
        dylibOffset(of: machO, in: cache.mainCache)
    }
}

fileprivate extension MachOFile {
    func textOffset(in cache: DyldCache) -> UInt64? {
        let loadCommands = loadCommands
        let text: (any SegmentCommandProtocol)? = loadCommands.text64 ?? loadCommands.text
        guard let text else { return nil }
        return numericCast(text.virtualMemoryAddress) - cache.mainCacheHeader.sharedRegionStart
    }

    func textOffset(in cache: FullDyldCache) -> UInt64? {
        textOffset(in: cache.mainCache)
    }
}
