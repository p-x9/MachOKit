let benchmarks: @Sendable () -> Void = {
    registerMachOFileBenchmarks()
    registerRebaseBindBenchmarks()
    registerDyldCacheBenchmarks()
    registerFullDyldCacheBenchmarks()
}
