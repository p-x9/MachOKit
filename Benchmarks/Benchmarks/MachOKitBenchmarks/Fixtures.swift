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

    static func machOFile() -> MachOFile {
        do {
            return try MachOFile(url: machOURL)
        } catch {
            fatalError("Failed to load Mach-O benchmark fixture at \(machOURL.path): \(error)")
        }
    }

    static func dyldCache() -> DyldCache? {
        guard let dyldCacheURL else { return nil }
        do {
            return try DyldCache(url: dyldCacheURL)
        } catch {
            fatalError("Failed to load dyld cache benchmark fixture at \(dyldCacheURL.path): \(error)")
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
}
