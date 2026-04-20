import Foundation
import MachOKit

extension DylibUseFlags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .weak_link: "Weak Link"
        case .reexport: "Re-export"
        case .upward: "Upward"
        case .delayed_init: "Delayed Initialization"
        }
    }
}

extension DylibUseFlags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension DylibUseFlags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}
