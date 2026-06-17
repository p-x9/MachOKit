import Benchmark
import Foundation
import MachOKit

func registerRebaseBindBenchmarks() {
    Benchmark("MachOFile.rebaseOperations.enumerate") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let operations = machO.rebaseOperations

        benchmark.startMeasurement()

        var count = 0
        if let operations {
            for operation in operations {
                blackHole(operation)
                count += 1
            }
        }
        blackHole(count)
    }

    Benchmark("MachOFile.bindOperations.enumerate") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let operations = [
            machO.bindOperations,
            machO.weakBindOperations,
            machO.lazyBindOperations,
        ]

        benchmark.startMeasurement()

        var count = 0
        for operations in operations {
            guard let operations else { continue }
            for operation in operations {
                blackHole(operation)
                count += 1
            }
        }
        blackHole(count)
    }

    Benchmark("MachOFile.rebases.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let rebases = BenchmarkFixtures.classicRebases(from: machO, benchmark: benchmark) else {
            return
        }
        blackHole(rebases)
        let iterations = 100

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.rebases)
        }
    }

    Benchmark("MachOFile.bindings.repeated") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let bindings = BenchmarkFixtures.classicBindings(from: machO, benchmark: benchmark) else {
            return
        }
        blackHole(bindings)
        let iterations = 100

        benchmark.startMeasurement()

        for _ in 0..<iterations {
            blackHole(machO.bindingSymbols)
            blackHole(machO.weakBindingSymbols)
            blackHole(machO.lazyBindingSymbols)
        }
    }

    Benchmark("MachOFile.rebases.segmentLookup") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let rebases = BenchmarkFixtures.classicRebases(from: machO, benchmark: benchmark) else {
            return
        }

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

    Benchmark("MachOFile.rebases.sectionLookup") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let rebases = BenchmarkFixtures.classicRebases(from: machO, benchmark: benchmark) else {
            return
        }

        benchmark.startMeasurement()

        if machO.is64Bit {
            for rebase in rebases {
                blackHole(rebase.section64(in: machO))
            }
        } else {
            for rebase in rebases {
                blackHole(rebase.section32(in: machO))
            }
        }
    }

    Benchmark("MachOFile.rebases.address") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let rebases = BenchmarkFixtures.classicRebases(from: machO, benchmark: benchmark) else {
            return
        }

        benchmark.startMeasurement()

        for rebase in rebases {
            blackHole(rebase.address(in: machO))
        }
    }

    Benchmark("MachOFile.bindings.segmentLookup") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let bindings = BenchmarkFixtures.classicBindings(from: machO, benchmark: benchmark) else {
            return
        }

        benchmark.startMeasurement()

        if machO.is64Bit {
            for binding in bindings {
                blackHole(binding.segment64(in: machO))
            }
        } else {
            for binding in bindings {
                blackHole(binding.segment32(in: machO))
            }
        }
    }

    Benchmark("MachOFile.bindings.sectionLookup") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let bindings = BenchmarkFixtures.classicBindings(from: machO, benchmark: benchmark) else {
            return
        }

        benchmark.startMeasurement()

        if machO.is64Bit {
            for binding in bindings {
                blackHole(binding.section64(in: machO))
            }
        } else {
            for binding in bindings {
                blackHole(binding.section32(in: machO))
            }
        }
    }

    Benchmark("MachOFile.bindings.libraryLookup") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let bindings = BenchmarkFixtures.classicBindings(from: machO, benchmark: benchmark) else {
            return
        }

        benchmark.startMeasurement()

        for binding in bindings {
            blackHole(binding.library(in: machO))
        }
    }

    Benchmark("MachOFile.bindings.address") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        guard let bindings = BenchmarkFixtures.classicBindings(from: machO, benchmark: benchmark) else {
            return
        }

        benchmark.startMeasurement()

        for binding in bindings {
            blackHole(binding.address(in: machO))
        }
    }

    Benchmark("MachOFile.dyldChainedFixups.metadata") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let chainedFixups = machO.dyldChainedFixups

        benchmark.startMeasurement()

        guard let chainedFixups else { return }
        blackHole(chainedFixups.header)
        blackHole(chainedFixups.startsInImage)
        if let startsInImage = chainedFixups.startsInImage {
            let startsInSegments = chainedFixups.startsInSegments(of: startsInImage)
            blackHole(startsInSegments)
            for segment in startsInSegments {
                blackHole(chainedFixups.pages(of: segment))
            }
        }
        blackHole(chainedFixups.imports)
    }

    Benchmark("MachOFile.dyldChainedFixups.pointers") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let chainedFixups = machO.dyldChainedFixups
        let startsInImage = chainedFixups?.startsInImage
        let startsInSegments = chainedFixups?.startsInSegments(of: startsInImage) ?? []

        benchmark.startMeasurement()

        var count = 0
        if let chainedFixups {
            for segment in startsInSegments {
                let pointers = chainedFixups.pointers(of: segment, in: machO)
                count += pointers.count
                blackHole(pointers)
            }
        }
        blackHole(count)
    }

    Benchmark("MachOFile.dyldChainedFixups.pointerLookup") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let chainedFixups = machO.dyldChainedFixups
        let offsets = BenchmarkFixtures.chainedFixupPointers(from: machO, limit: 1_000)
            .map { UInt64($0.offset) }

        benchmark.startMeasurement()

        if let chainedFixups {
            for offset in offsets {
                blackHole(chainedFixups.pointer(for: offset, in: machO))
            }
        }
    }

    Benchmark("MachOFile.resolveRebase") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let offsets = BenchmarkFixtures.chainedFixupPointers(from: machO, limit: 1_000)
            .filter { $0.fixupInfo.rebase != nil }
            .map { UInt64($0.offset) }

        benchmark.startMeasurement()

        for offset in offsets {
            blackHole(machO.resolveRebase(at: offset))
        }
    }

    Benchmark("MachOFile.resolveOptionalRebase") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let offsets = BenchmarkFixtures.chainedFixupPointers(from: machO, limit: 1_000)
            .filter { $0.fixupInfo.rebase != nil }
            .map { UInt64($0.offset) }

        benchmark.startMeasurement()

        for offset in offsets {
            blackHole(machO.resolveOptionalRebase(at: offset))
        }
    }

    Benchmark("MachOFile.resolveBind") { benchmark in
        let machO = BenchmarkFixtures.machOFile()
        let offsets = BenchmarkFixtures.chainedFixupPointers(from: machO, limit: 1_000)
            .filter { $0.fixupInfo.bind != nil }
            .map { UInt64($0.offset) }

        benchmark.startMeasurement()

        for offset in offsets {
            blackHole(machO.resolveBind(at: offset))
        }
    }
}
