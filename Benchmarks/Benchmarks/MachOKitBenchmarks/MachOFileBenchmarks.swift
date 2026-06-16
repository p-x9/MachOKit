import Benchmark
import Foundation
import MachOKit

func registerMachOFileBenchmarks() {
    Benchmark("MachOFile.loadCommands.enumerate") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let iterations = 100

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            var count = 0
            for command in machO.loadCommands {
                blackHole(command)
                count += 1
            }
            blackHole(count)
        }
    }

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

    Benchmark("MachOFile.dependencies.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let iterations = 1_000

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.dependencies)
        }
    }

    Benchmark("MachOFile.exportedSymbols.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let iterations = 100

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.exportedSymbols)
        }
    }

    Benchmark("MachOFile.exportTrie.search") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let exportTrie = machO.exportTrie else { return }
        let names = BenchmarkFixtures.exportedSymbolNames(from: machO, limit: 1_000)
        guard !names.isEmpty else { return }

        benchmark.startMeasurement()

        for name in names {
            blackHole(exportTrie.search(by: name))
        }
    }

    Benchmark("MachOFile.exportTrie.prefixSearch") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let exportTrie = machO.exportTrie else { return }
        let prefixes = BenchmarkFixtures.exportedSymbolPrefixes(from: machO, limit: 100)
        guard !prefixes.isEmpty else { return }

        benchmark.startMeasurement()

        for prefix in prefixes {
            blackHole(exportTrie.search(byKeyPrefix: prefix))
        }
    }

    Benchmark("MachOFile.exportTrie.entries") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let exportTrie = machO.exportTrie else { return }
        let iterations = 10

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(exportTrie.entries)
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

    Benchmark("MachOFile.sections.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let iterations = 1_000

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.sections)
        }
    }

    Benchmark("MachOFile.allCStringTables.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let iterations = 100

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.allCStringTables)
        }
    }

    Benchmark("MachOFile.functionStarts.enumerate") { benchmark in
        let machO = BenchmarkFixtures.machOFile()

        benchmark.startMeasurement()

        var count = 0
        if let functionStarts = machO.functionStarts {
            for functionStart in functionStarts {
                blackHole(functionStart)
                count += 1
            }
        }
        blackHole(count)
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

    Benchmark("MachOFile.fileOffset.translate") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let addresses = BenchmarkFixtures.machOAddresses(from: machO, limit: 100_000)

        benchmark.startMeasurement()

        for address in addresses {
            blackHole(machO.fileOffset(of: address))
        }
    }

    Benchmark("MachOFile.contains.unslidAddress") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let addresses = BenchmarkFixtures.machOAddresses(from: machO, limit: 100_000)

        benchmark.startMeasurement()

        for address in addresses {
            blackHole(machO.contains(unslidAddress: address))
        }
    }

}
