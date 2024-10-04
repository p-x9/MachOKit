//
//  ObjCImageInfo.swift
//
//
//  Created by p-x9 on 2024/05/24
//
//

import Foundation

public struct ObjCImageInfo: LayoutWrapper {
    public typealias Layout = objc_image_info

    public var layout: Layout
}

extension ObjCImageInfo {
    public var version : Version {
        .init(numericCast(layout.version))
    }

    public var flags: ObjCImageInfoFlags {
        .init(rawValue: layout.flags)
    }
}

public struct ObjCImageInfoFlags: BitFlags {
    public typealias RawValue = UInt32
    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension ObjCImageInfoFlags {
    public var swiftUnstableVersion: SwiftVersion? {
        .init(rawValue: (rawValue & (0xff << 8)) >> 8)
    }

    public var swiftStableVersion: Version {
        Version((rawValue & (0xffff << 16)) >> 8)
    }
}

extension ObjCImageInfoFlags {
    public static var dyldCategoriesOptimized: Self {
        .init(rawValue: Bit.dyldCategoriesOptimized.rawValue)
    }

    public static var supportsGC: Self {
        .init(rawValue: Bit.supportsGC.rawValue)
    }

    public static var requiresGC: Self {
        .init(rawValue: Bit.requiresGC.rawValue)
    }

    public static var optimizedByDyld: Self {
        .init(rawValue: Bit.optimizedByDyld.rawValue)
    }

    public static var signedClassRO: Self {
        .init(rawValue: Bit.signedClassRO.rawValue)
    }

    public static var isSimulated: Self {
        .init(rawValue: Bit.isSimulated.rawValue)
    }

    public static var hasCategoryClassProperties: Self {
        .init(rawValue: Bit.hasCategoryClassProperties.rawValue)
    }

    public static var optimizedByDyldClosure: Self {
        .init(rawValue: Bit.optimizedByDyldClosure.rawValue)
    }
}

extension ObjCImageInfoFlags {
    public enum Bit: UInt32, CaseIterable {
        /// categories were optimized by dyld
        case dyldCategoriesOptimized     = 0x00000001
        /// image supports GC
        case supportsGC                  = 0x00000010
        /// image requires GC
        case requiresGC                  = 0x00000100
        /// image is from an optimized shared cache
        case optimizedByDyld             = 0x00001000
        /// class_ro_t pointers are signed
        case signedClassRO               = 0x00010000
        /// image compiled for a simulator platform
        case isSimulated                 = 0x00100000
        /// class properties in category_t
        case hasCategoryClassProperties  = 0x01000000
        /// dyld (not the shared cache) optimized this.
        case optimizedByDyldClosure      = 0x10000000
    }
}

extension ObjCImageInfoFlags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dyldCategoriesOptimized: "dyldCategoriesOptimized"
        case .supportsGC: "supportsGC"
        case .requiresGC: "requiresGC"
        case .optimizedByDyld: "optimizedByDyld"
        case .signedClassRO: "signedClassRO"
        case .isSimulated: "isSimulated"
        case .hasCategoryClassProperties: "hasCategoryClassProperties"
        case .optimizedByDyldClosure: "optimizedByDyldClosure"
        }
    }
}

extension ObjCImageInfoFlags {
    public enum SwiftVersion: UInt32 {
        case v1 = 1
        case v1_2
        case v2
        case v3
        case v4
        case v4_1
        case v4_2
        case v5
    }
}

extension ObjCImageInfoFlags.SwiftVersion: CustomStringConvertible {
    public var description: String {
        switch self {
        case .v1: "v1"
        case .v1_2: "v1.2"
        case .v2: "v2"
        case .v3: "v3"
        case .v4: "v4"
        case .v4_1: "v4.1"
        case .v4_2: "v4.2"
        case .v5: "v5"
        }
    }
}
