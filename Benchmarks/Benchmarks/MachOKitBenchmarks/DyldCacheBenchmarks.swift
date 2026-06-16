import Benchmark
import Foundation
import MachOKit

func registerDyldCacheBenchmarks() {
    guard BenchmarkFixtures.hasDyldCache else { return }

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
        guard let cache = BenchmarkFixtures.dyldCache() else { return }
        let addresses = BenchmarkFixtures.dyldCacheAddresses(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for address in addresses {
            blackHole(cache.fileOffset(of: address))
        }
    }

    Benchmark("DyldCache.address.translate") { benchmark in
        guard let cache = BenchmarkFixtures.dyldCache() else { return }
        let fileOffsets = BenchmarkFixtures.dyldCacheFileOffsets(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for fileOffset in fileOffsets {
            blackHole(cache.address(of: fileOffset))
        }
    }

    Benchmark("DyldCache.mappingInfo.lookup") { benchmark in
        guard let cache = BenchmarkFixtures.dyldCache() else { return }
        let addresses = BenchmarkFixtures.dyldCacheAddresses(from: cache, limit: 100_000)
        let fileOffsets = BenchmarkFixtures.dyldCacheFileOffsets(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for address in addresses {
            blackHole(cache.mappingInfo(for: address))
            blackHole(cache.mappingAndSlideInfo(for: address))
        }
        for fileOffset in fileOffsets {
            blackHole(cache.mappingInfo(forFileOffset: fileOffset))
            blackHole(cache.mappingAndSlideInfo(forFileOffset: fileOffset))
        }
    }

    Benchmark("DyldCache.resolveRebase") { benchmark in
        guard let cache = BenchmarkFixtures.dyldCache() else { return }
        let fileOffsets = BenchmarkFixtures.dyldCachePointerFileOffsets(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for fileOffset in fileOffsets {
            blackHole(cache.resolveRebase(at: fileOffset))
        }
    }

    Benchmark("DyldCache.resolveOptionalRebase") { benchmark in
        guard let cache = BenchmarkFixtures.dyldCache() else { return }
        let fileOffsets = BenchmarkFixtures.dyldCachePointerFileOffsets(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for fileOffset in fileOffsets {
            blackHole(cache.resolveOptionalRebase(at: fileOffset))
        }
    }
}
