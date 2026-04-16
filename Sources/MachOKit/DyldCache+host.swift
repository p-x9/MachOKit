import Foundation
import MachOKitC

extension DyldCache {
    public static var host: DyldCache? {
        #if canImport(Darwin)
        guard let path = _DyldSharedCacheRuntime.sharedCacheFilePath() else {
            return nil
        }
        let url: URL = .init(fileURLWithPath: path)
        return try? DyldCache(url: url)
        #else
        return nil
        #endif
    }
}
