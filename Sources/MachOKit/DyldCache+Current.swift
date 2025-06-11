import Foundation
import MachOKitC

extension DyldCache {
    public var current: DyldCache? {
        #if os(macOS)
        return try? DyldCache(url: .init(fileURLWithPath: .init(cString: dyld_shared_cache_file_path())))
        #else
        return nil
        #endif
    }
}
