import Benchmark
import Foundation
import MachOKit

func registerFullDyldCacheBenchmarks() {
    guard BenchmarkFixtures.hasFullDyldCache else { return }

    Benchmark("FullDyldCache.machOFiles.enumerate") { benchmark in
        guard let cache = BenchmarkFixtures.fullDyldCache() else { return }

        benchmark.startMeasurement()

        var count = 0
        for machO in cache.machOFiles() {
            blackHole(machO)
            count += 1
        }
        blackHole(count)
    }

    Benchmark("FullDyldCache.fileOffset.translate") { benchmark in
        guard let cache = BenchmarkFixtures.fullDyldCache() else { return }
        let addresses = BenchmarkFixtures.dyldCacheAddresses(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for address in addresses {
            blackHole(cache.fileOffset(of: address))
        }
    }

    Benchmark("FullDyldCache.mappingInfo.lookup") { benchmark in
        guard let cache = BenchmarkFixtures.fullDyldCache() else { return }
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

    Benchmark("FullDyldCache.cache.forOffset") { benchmark in
        guard let cache = BenchmarkFixtures.fullDyldCache() else { return }
        let fileOffsets = BenchmarkFixtures.dyldCacheFileOffsetsAcrossMappings(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for fileOffset in fileOffsets {
            blackHole(cache.cache(forOffset: fileOffset))
        }
    }

    Benchmark("FullDyldCache.cache.forURL") { benchmark in
        guard let cache = BenchmarkFixtures.fullDyldCache() else { return }
        let urls = cache.urls
        let iterations = 100_000

        benchmark.startMeasurement()

        for index in 0..<iterations {
            blackHole(cache.cache(for: urls[index % urls.count]))
        }
    }

    Benchmark("FullDyldCache.resolveRebase") { benchmark in
        guard let cache = BenchmarkFixtures.fullDyldCache() else { return }
        let fileOffsets = BenchmarkFixtures.dyldCachePointerFileOffsets(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for fileOffset in fileOffsets {
            blackHole(cache.resolveRebase(at: fileOffset))
        }
    }

    Benchmark("FullDyldCache.resolveOptionalRebase") { benchmark in
        guard let cache = BenchmarkFixtures.fullDyldCache() else { return }
        let fileOffsets = BenchmarkFixtures.dyldCachePointerFileOffsets(from: cache, limit: 100_000)

        benchmark.startMeasurement()

        for fileOffset in fileOffsets {
            blackHole(cache.resolveOptionalRebase(at: fileOffset))
        }
    }
}
