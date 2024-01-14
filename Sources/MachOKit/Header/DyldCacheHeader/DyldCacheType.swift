//
//  DyldCacheType.swift
//  
//
//  Created by p-x9 on 2024/01/14.
//  
//

import Foundation

public enum DyldCacheType: UInt64 {
    case development
    case production
    case multiCache
}

public enum DyldCacheSubType: UInt32 {
    case development
    case production
}
