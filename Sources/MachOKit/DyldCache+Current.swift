import Foundation

extension DyldCache {
    public var current: DyldCache? {
        #if os(macOS)
        let majorVersion = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        guard let cpu = CPU.current else { return nil }
        let prefix: String
        let filename: String
        let dir = "/System/Library/dyld/"
        switch majorVersion {
        case 10 ..< 11:
            return try? DyldCache(url: .init(fileURLWithPath: "/private/var/db/dyld/dyld_shared_cache_x86_64"))
        case 11 ..< 13:
            prefix = "/System/Cryptexes/OS"
        case 13...:
            prefix = "/System/Volumes/Preboot/Cryptexes/OS"
        default:
            return nil
        }

        switch cpu.type {
        case .x86_64:
            switch cpu.subtype {
            case .x86(.x86_64_h):
                filename = "dyld_shared_cache_x86_64h"
            case .x86(.x86_64_all):
                filename = "dyld_shared_cache_x86_64"
            default:
                return nil
            }
        case .arm64:
            filename = "dyld_shared_cache_arm64e"
        default:
            return nil
        }
        return try? DyldCache(url: .init(fileURLWithPath: "\(prefix)\(dir)\(filename)"))
        #else
        return nil
        #endif
    }
}
