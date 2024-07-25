//
//  DyldCacheSlideInfo.swift
//
//
//  Created by p-x9 on 2024/07/23
//  
//

import Foundation
import MachOKitC

public enum DyldCacheSlideInfo {
    case v1(DyldCacheSlideInfo1)
    case v2(DyldCacheSlideInfo2)
    case v3(DyldCacheSlideInfo3)
    case v4(DyldCacheSlideInfo4)
    case v5(DyldCacheSlideInfo5)
}

extension DyldCacheSlideInfo {
    public enum Version: Int {
        case v1 = 1, v2, v3, v4, v5
    }
}

extension DyldCacheSlideInfo.Version: Comparable {
    public static func < (lhs: DyldCacheSlideInfo.Version, rhs: DyldCacheSlideInfo.Version) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension DyldCacheSlideInfo {
    public var version: Version {
        switch self {
        case .v1: .v1
        case .v2: .v2
        case .v3: .v3
        case .v4: .v4
        case .v5: .v5
        }
    }
}
