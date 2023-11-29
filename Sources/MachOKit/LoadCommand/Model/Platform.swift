//
//  Platform.swift
//  
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public enum Platform {
    case unknown
    case any
    case macOS
    case iOS
    case tvOS
    case watchOS
    case bridgeOS
    case macCatalyst
    case iOSSimulator
    case tvOSSimulator
    case watchOSSimulator
    case driverKit

    // __OPEN_SOURCE__
    case firmware
    case sepOS
}

extension Platform: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case UInt32(PLATFORM_UNKNOWN): self = .unknown
        case PLATFORM_ANY: self = .any
        case UInt32(PLATFORM_MACOS): self = .macOS
        case UInt32(PLATFORM_IOS): self = .iOS
        case UInt32(PLATFORM_TVOS): self = .tvOS
        case UInt32(PLATFORM_WATCHOS): self = .watchOS
        case UInt32(PLATFORM_BRIDGEOS):self = .bridgeOS
        case UInt32(PLATFORM_MACCATALYST): self = .macCatalyst
        case UInt32(PLATFORM_IOSSIMULATOR): self = .iOSSimulator
        case UInt32(PLATFORM_TVOSSIMULATOR): self = .tvOSSimulator
        case UInt32(PLATFORM_WATCHOSSIMULATOR): self = .watchOSSimulator
        case UInt32(PLATFORM_DRIVERKIT): self = .driverKit
        default:
            return nil
        }
    }

    public var rawValue: UInt32 {
        switch self {
        case .unknown: UInt32(PLATFORM_UNKNOWN)
        case .any: PLATFORM_ANY
        case .macOS: UInt32(PLATFORM_MACOS)
        case .iOS: UInt32(PLATFORM_IOS)
        case .tvOS: UInt32(PLATFORM_TVOS)
        case .watchOS: UInt32(PLATFORM_WATCHOS)
        case .bridgeOS: UInt32(PLATFORM_BRIDGEOS)
        case .macCatalyst: UInt32(PLATFORM_MACCATALYST)
        case .iOSSimulator: UInt32(PLATFORM_IOSSIMULATOR)
        case .tvOSSimulator: UInt32(PLATFORM_TVOSSIMULATOR)
        case .watchOSSimulator: UInt32(PLATFORM_WATCHOSSIMULATOR)
        case .driverKit: UInt32(PLATFORM_DRIVERKIT)
        case .firmware: UInt32(PLATFORM_FIRMWARE)
        case .sepOS: UInt32(PLATFORM_SEPOS)
        }
    }
}

extension Platform: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unknown: "PLATFORM_UNKNOWN"
        case .any: "PLATFORM_ANY"
        case .macOS: "PLATFORM_MACOS"
        case .iOS: "PLATFORM_IOS"
        case .tvOS: "PLATFORM_TVOS"
        case .watchOS: "PLATFORM_WATCHOS"
        case .bridgeOS: "PLATFORM_BRIDGEOS"
        case .macCatalyst: "PLATFORM_MACCATALYST"
        case .iOSSimulator: "PLATFORM_IOSSIMULATOR"
        case .tvOSSimulator: "PLATFORM_TVOSSIMULATOR"
        case .watchOSSimulator: "PLATFORM_WATCHOSSIMULATOR"
        case .driverKit: "PLATFORM_DRIVERKIT"
        case .firmware: "PLATFORM_FIRMWARE"
        case .sepOS: "PLATFORM_SEPOS"
        }
    }
}
