import Foundation
import MachOKitC

extension DyldCache {
    public var current: DyldCache? {
        #if canImport(Darwin)
        guard let ptr = dyld_shared_cache_file_path() else {
            return nil
        }
        let url: URL = .init(fileURLWithPath: .init(cString: ptr))
        return try? DyldCache(url: url)
        #else
        return nil
        #endif
    }
}
