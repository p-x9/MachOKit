//
//  DyldCacheMappingFlags.swift
//
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheMappingFlags: BitFlags {
    public typealias RawValue = UInt64

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension DyldCacheMappingFlags {
    /// DYLD_CACHE_MAPPING_AUTH_DATA
    public static let authData = DyldCacheMappingFlags(
        rawValue: Bit.authData.rawValue
    )
    /// DYLD_CACHE_MAPPING_DIRTY_DATA
    public static let dirtyData = DyldCacheMappingFlags(
        rawValue: Bit.dirtyData.rawValue
    )
    /// DYLD_CACHE_MAPPING_CONST_DATA
    public static let constData = DyldCacheMappingFlags(
        rawValue: Bit.constData.rawValue
    )
    /// DYLD_CACHE_MAPPING_TEXT_STUBS
    public static let textStubs = DyldCacheMappingFlags(
        rawValue: Bit.textStubs.rawValue
    )
    /// DYLD_CACHE_DYNAMIC_CONFIG_DATA
    public static let configData = DyldCacheMappingFlags(
        rawValue: Bit.configData.rawValue
    )
}

extension DyldCacheMappingFlags {
    public enum Bit: CaseIterable {
        /// DYLD_CACHE_MAPPING_AUTH_DATA
        case authData
        /// DYLD_CACHE_MAPPING_DIRTY_DATA
        case dirtyData
        /// DYLD_CACHE_MAPPING_CONST_DATA
        case constData
        /// DYLD_CACHE_MAPPING_TEXT_STUBS
        case textStubs
        /// DYLD_CACHE_DYNAMIC_CONFIG_DATA
        case configData
    }
}

extension DyldCacheMappingFlags.Bit: RawRepresentable {
    public typealias RawValue = UInt64

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(DYLD_CACHE_MAPPING_AUTH_DATA): self = .authData
        case RawValue(DYLD_CACHE_MAPPING_DIRTY_DATA): self = .dirtyData
        case RawValue(DYLD_CACHE_MAPPING_CONST_DATA): self = .constData
        case RawValue(DYLD_CACHE_MAPPING_TEXT_STUBS): self = .textStubs
        case RawValue(DYLD_CACHE_DYNAMIC_CONFIG_DATA): self = .configData
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .authData: RawValue(DYLD_CACHE_MAPPING_AUTH_DATA)
        case .dirtyData: RawValue(DYLD_CACHE_MAPPING_DIRTY_DATA)
        case .constData: RawValue(DYLD_CACHE_MAPPING_CONST_DATA)
        case .textStubs: RawValue(DYLD_CACHE_MAPPING_TEXT_STUBS)
        case .configData: RawValue(DYLD_CACHE_DYNAMIC_CONFIG_DATA)
        }
    }
}

extension DyldCacheMappingFlags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .authData: "DYLD_CACHE_MAPPING_AUTH_DATA"
        case .dirtyData: "DYLD_CACHE_MAPPING_DIRTY_DATA"
        case .constData: "DYLD_CACHE_MAPPING_CONST_DATA"
        case .textStubs: "DYLD_CACHE_MAPPING_TEXT_STUBS"
        case .configData: "DYLD_CACHE_DYNAMIC_CONFIG_DATA"
        }
    }
}
