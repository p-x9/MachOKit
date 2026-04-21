import Foundation
import MachOKit

extension VMProtection.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .read: "Read"
        case .write: "Write"
        case .execute: "Execute"
        case .no_change: "No Change"
        case .copy: "Copy"
        case .is_mask: "Mask"
        case .strip_read: "Strip Read"
        }
    }
}

extension VMProtection {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension VMProtection: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}
