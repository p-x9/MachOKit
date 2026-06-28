import Benchmark
import Foundation
import MachOKit

enum BenchmarkFixtures {
    static var machOURL: URL {
        if let path = ProcessInfo.processInfo.environment["MACHOKIT_BENCH_MACHO"],
           !path.isEmpty {
            return URL(fileURLWithPath: path)
        }
        if let executableURL = Bundle.main.executableURL {
            return executableURL
        }
        return URL(fileURLWithPath: CommandLine.arguments[0])
    }

    static var dyldCacheURL: URL? {
        guard let path = ProcessInfo.processInfo.environment["MACHOKIT_BENCH_DYLD_CACHE"],
              !path.isEmpty else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    static var fullDyldCacheURL: URL? {
        guard let path = ProcessInfo.processInfo.environment["MACHOKIT_BENCH_FULL_DYLD_CACHE"],
              !path.isEmpty else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    static var hasDyldCache: Bool {
        #if canImport(Darwin)
        true
        #else
        dyldCacheURL != nil
        #endif
    }

    static var hasFullDyldCache: Bool {
        #if canImport(Darwin)
        true
        #else
        fullDyldCacheURL != nil
        #endif
    }

    static func machOFile() -> MachOFile {
        do {
            return try MachOFile(url: machOURL)
        } catch {
            fatalError("Failed to load Mach-O benchmark fixture at \(machOURL.path): \(error)")
        }
    }

    static func classicRebases(from machO: MachOFile, benchmark: Benchmark) -> [Rebase]? {
        let rebases = machO.rebases
        guard !rebases.isEmpty else {
            benchmark.error(
                """
                Mach-O benchmark fixture has no classic dyld rebase opcodes: \(machO.url.path).
                Set MACHOKIT_BENCH_MACHO to a thin Mach-O with LC_DYLD_INFO_ONLY rebase data.
                """
            )
            return nil
        }
        return rebases
    }

    static func classicBindings(from machO: MachOFile, benchmark: Benchmark) -> [BindingSymbol]? {
        let bindings = machO.bindingSymbols + machO.weakBindingSymbols + machO.lazyBindingSymbols
        guard !bindings.isEmpty else {
            benchmark.error(
                """
                Mach-O benchmark fixture has no classic dyld bind opcodes: \(machO.url.path).
                Set MACHOKIT_BENCH_MACHO to a thin Mach-O with LC_DYLD_INFO_ONLY bind data.
                """
            )
            return nil
        }
        return bindings
    }

    static func dyldCache() -> DyldCache? {
        guard let dyldCacheURL else {
            return DyldCache.host
        }
        do {
            return try DyldCache(url: dyldCacheURL)
        } catch {
            fatalError("Failed to load dyld cache benchmark fixture at \(dyldCacheURL.path): \(error)")
        }
    }

    static func fullDyldCache() -> FullDyldCache? {
        guard let fullDyldCacheURL else {
            return FullDyldCache.host
        }
        do {
            return try FullDyldCache(url: fullDyldCacheURL)
        } catch {
            fatalError("Failed to load full dyld cache benchmark fixture at \(fullDyldCacheURL.path): \(error)")
        }
    }

    static func symbolOffsets(from machO: MachOFile, limit: Int) -> [Int] {
        let offsets = machO.symbols.lazy
            .map(\.offset)
            .filter { $0 >= 0 }
            .prefix(limit)
        let result = Array(offsets)
        return result.isEmpty ? [0] : result
    }

    static func symbolName(from machO: MachOFile) -> String? {
        machO.symbols.first?.name
    }

    static func exportedSymbolNames(from machO: MachOFile, limit: Int) -> [String] {
        guard let exportTrie = machO.exportTrie else {
            return []
        }
        return Array(
            exportTrie.exportedSymbols.lazy
                .map(\.name)
                .filter { !$0.isEmpty }
                .prefix(limit)
        )
    }

    static func exportedSymbolPrefixes(from machO: MachOFile, limit: Int) -> [String] {
        let prefixes = exportedSymbolNames(from: machO, limit: limit)
            .map { String($0.prefix(8)) }
            .filter { !$0.isEmpty }
        return prefixes.isEmpty ? [] : prefixes
    }

    static func machOAddresses(from machO: MachOFile, limit: Int) -> [UInt64] {
        let addresses = machO.segments.lazy.flatMap { segment in
            stride(
                from: 0,
                to: max(segment.virtualMemorySize, 1),
                by: max(segment.virtualMemorySize / 64, 1)
            )
            .lazy
            .map { UInt64(segment.virtualMemoryAddress + $0) }
        }
        let result = Array(addresses.prefix(limit))
        return result.isEmpty ? [0] : result
    }

    static func dyldCacheAddresses(from cache: some DyldCacheRepresentable, limit: Int) -> [UInt64] {
        guard let mapping = cache.mappingInfos?.first,
              mapping.size > 0 else {
            return []
        }
        return (0..<limit).map {
            mapping.address + UInt64($0) % mapping.size
        }
    }

    static func dyldCacheFileOffsets(from cache: some DyldCacheRepresentable, limit: Int) -> [UInt64] {
        guard let mapping = cache.mappingInfos?.first,
              mapping.size > 0 else {
            return []
        }
        return (0..<limit).map {
            mapping.fileOffset + UInt64($0) % mapping.size
        }
    }

    static func dyldCacheFileOffsetsAcrossMappings(
        from cache: some DyldCacheRepresentable,
        limit: Int
    ) -> [UInt64] {
        guard let mappings = cache.mappingInfos,
              !mappings.isEmpty else {
            return []
        }

        return (0..<limit).compactMap { index in
            let mapping = mappings[mappings.index(mappings.startIndex, offsetBy: index % mappings.count)]
            guard mapping.size > 0 else {
                return nil
            }
            return mapping.fileOffset + UInt64(index) % mapping.size
        }
    }

    static func dyldCachePointerFileOffsets(from cache: some DyldCacheRepresentable, limit: Int) -> [UInt64] {
        guard let mapping = cache.mappingInfos?.first else {
            return []
        }

        let pointerSize: UInt64 = cache.cpu.is64Bit ? 8 : 4
        guard mapping.size >= pointerSize else {
            return []
        }

        let pointerCount = max(mapping.size / pointerSize, 1)
        return (0..<limit).map {
            mapping.fileOffset + (UInt64($0) % pointerCount) * pointerSize
        }
    }

    static func chainedFixupPointers(
        from machO: MachOFile,
        limit: Int
    ) -> [DyldChainedFixupPointer] {
        guard let chainedFixups = machO.dyldChainedFixups,
              let startsInImage = chainedFixups.startsInImage else {
            return []
        }

        var pointers: [DyldChainedFixupPointer] = []
        for segment in chainedFixups.startsInSegments(of: startsInImage) {
            pointers += chainedFixups.pointers(of: segment, in: machO)
            if pointers.count >= limit {
                return Array(pointers.prefix(limit))
            }
        }
        return pointers
    }
}
