//
//  DylibUseFlags.swift
//  MachOKit
//
//  Created by p-x9 on 2024/12/12
//
//

import Foundation

public struct DylibUseFlags: BitFlags {
    public typealias RawValue = UInt32

    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension DylibUseFlags {
    /// DYLIB_USE_WEAK_LINK
    public static let weak_link = MachHeader.Flags(
        rawValue: Bit.weak_link.rawValue
    )
    /// DYLIB_USE_REEXPORT
    public static let reexport = MachHeader.Flags(
        rawValue: Bit.reexport.rawValue
    )
    /// DYLIB_USE_UPWARD
    public static let upward = MachHeader.Flags(
        rawValue: Bit.upward.rawValue
    )
    /// DYLIB_USE_DELAYED_INIT
    public static let delayed_init = MachHeader.Flags(
        rawValue: Bit.delayed_init.rawValue
    )
}

extension DylibUseFlags {
    public enum Bit: CaseIterable {
        /// DYLIB_USE_WEAK_LINK
        case weak_link
        /// DYLIB_USE_REEXPORT
        case reexport
        /// DYLIB_USE_UPWARD
        case upward
        /// DYLIB_USE_DELAYED_INIT
        case delayed_init
    }
}

extension DylibUseFlags.Bit: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(DYLIB_USE_WEAK_LINK): self = .weak_link
        case RawValue(DYLIB_USE_REEXPORT): self = .reexport
        case RawValue(DYLIB_USE_UPWARD): self = .upward
        case RawValue(DYLIB_USE_DELAYED_INIT): self = .delayed_init
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .weak_link: RawValue(DYLIB_USE_WEAK_LINK)
        case .reexport: RawValue(DYLIB_USE_REEXPORT)
        case .upward: RawValue(DYLIB_USE_UPWARD)
        case .delayed_init: RawValue(DYLIB_USE_DELAYED_INIT)
        }
    }
}

extension DylibUseFlags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .weak_link: "DYLIB_USE_WEAK_LINK"
        case .reexport: "DYLIB_USE_REEXPORT"
        case .upward: "DYLIB_USE_UPWARD"
        case .delayed_init: "DYLIB_USE_DELAYED_INIT"
        }
    }
}
