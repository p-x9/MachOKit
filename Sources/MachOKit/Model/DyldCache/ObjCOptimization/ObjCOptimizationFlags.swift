//
//  ObjCOptimizationFlags.swift
//  MachOKit
//
//  Created by p-x9 on 2025/10/07
//  
//

import Foundation

public struct ObjCOptimizationFlags: BitFlags {
    public typealias RawValue = UInt32

    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

// ref: https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/include/objc-shared-cache.h#L84
extension ObjCOptimizationFlags {
    public enum Bit: RawValue, Sendable, CaseIterable {
        /// never set in development cache
        case isProduction = 1
        /// set in development cache and customer
        case noMissingWeakSuperclasses = 2
        /// Shared cache was built with the new Large format
        case largeSharedCache = 4
    }
}

extension ObjCOptimizationFlags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .isProduction: "IsProduction"
        case .noMissingWeakSuperclasses: "NoMissingWeakSuperclasses"
        case .largeSharedCache: "LargeSharedCache"
        }
    }
}
