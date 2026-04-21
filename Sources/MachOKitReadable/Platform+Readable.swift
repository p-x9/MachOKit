import Foundation
import MachOKit

extension Platform: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .unknown: "Unknown"
        case .any: "Any"
        case .macOS: "macOS"
        case .iOS: "iOS"
        case .tvOS: "tvOS"
        case .watchOS: "watchOS"
        case .bridgeOS: "bridgeOS"
        case .macCatalyst: "Mac Catalyst"
        case .iOSSimulator: "iOS Simulator"
        case .tvOSSimulator: "tvOS Simulator"
        case .watchOSSimulator: "watchOS Simulator"
        case .driverKit: "DriverKit"
        case .visionOS: "visionOS"
        case .visionOSSimulator: "visionOS Simulator"
        case .firmware: "Firmware"
        case .sepOS: "SEP OS"
        case .macOSExclaveCore: "macOS Exclave Core"
        case .macOSExclaveKit: "macOS Exclave Kit"
        case .iOSExclaveCore: "iOS Exclave Core"
        case .iOSExclaveKit: "iOS Exclave Kit"
        case .tvOSExclaveCore: "tvOS Exclave Core"
        case .tvOSExclaveKit: "tvOS Exclave Kit"
        case .watchOSExclaveCore: "watchOS Exclave Core"
        case .watchOSExclaveKit: "watchOS Exclave Kit"
        case .visionOSExclaveCore: "visionOS Exclave Core"
        case .visionOSExclaveKit: "visionOS Exclave Kit"
        }
    }
}
