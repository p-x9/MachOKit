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
        guard let path = _MachOKitDyldRuntime.sharedCacheFilePath() else {
            return nil
        }
        let url: URL = .init(fileURLWithPath: path)
        return try? FullDyldCache(url: url)
#else
        return nil
#endif
    }
}
