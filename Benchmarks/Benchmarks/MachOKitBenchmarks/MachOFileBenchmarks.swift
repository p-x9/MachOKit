import Benchmark
import Foundation
import MachOKit

let benchmarks: @Sendable () -> Void = {
    Benchmark("MachOFile.symbols.enumerate") { benchmark in
        let machO = BenchmarkFixtures.machOFile()

        benchmark.startMeasurement()

        var count = 0
        for symbol in machO.symbols {
            blackHole(symbol)
            count += 1
        }
        blackHole(count)
    }

    Benchmark("MachOFile.exportedSymbols.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let iterations = 100

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.exportedSymbols)
        }
    }

    Benchmark("MachOFile.segments.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let iterations = 1_000

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.segments)
        }
    }

    Benchmark("MachOFile.rebases.segmentLookup") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let rebases = machO.rebases

        benchmark.startMeasurement()

        if machO.is64Bit {
            for rebase in rebases {
                blackHole(rebase.segment64(in: machO))
            }
        } else {
            for rebase in rebases {
                blackHole(rebase.segment32(in: machO))
            }
        }
    }

    Benchmark("MachOFile.closestSymbol.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let offsets = BenchmarkFixtures.symbolOffsets(from: machO, limit: 1_000)

        benchmark.startMeasurement()

        for offset in offsets {
            blackHole(machO.closestSymbol(at: offset))
        }
    }

    Benchmark("MachOFile.symbols.named") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let name = BenchmarkFixtures.symbolName(from: machO) ?? "__machokit_missing_symbol__"
        let iterations = 100

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.symbols(named: name))
            blackHole(machO.symbols(named: name, mangled: false))
        }
    }

    if BenchmarkFixtures.dyldCacheURL != nil {
        Benchmark("DyldCache.machOFiles.enumerate") { benchmark in
            guard let cache = BenchmarkFixtures.dyldCache() else { return }

            benchmark.startMeasurement()

            var count = 0
            for machO in cache.machOFiles() {
                blackHole(machO)
                count += 1
            }
            blackHole(count)
        }

        Benchmark("DyldCache.fileOffset.translate") { benchmark in
            guard let cache = BenchmarkFixtures.dyldCache(),
                  let mappings = cache.mappingInfos,
                  let firstMapping = mappings.first else {
                return
            }
            let addresses = (0..<100_000).map {
                firstMapping.address + UInt64($0) % firstMapping.size
            }

            benchmark.startMeasurement()

            for address in addresses {
                blackHole(cache.fileOffset(of: address))
            }
        }
    }
}
