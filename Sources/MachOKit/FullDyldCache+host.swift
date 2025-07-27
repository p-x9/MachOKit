//
//  FullDyldCache+host.swift
//  MachOKit
//
//  Created by p-x9 on 2025/07/28
//  
//

import Foundation
import MachOKitC

extension FullDyldCache {
    public static var host: FullDyldCache? {
#if canImport(Darwin)
        guard let ptr = dyld_shared_cache_file_path() else {
            return nil
        }
        let url: URL = .init(fileURLWithPath: .init(cString: ptr))
        return try? FullDyldCache(url: url)
#else
        return nil
#endif
    }
}
