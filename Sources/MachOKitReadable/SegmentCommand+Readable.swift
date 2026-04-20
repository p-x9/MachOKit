import Foundation
import MachOKit

extension SegmentCommandFlags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .highvm: "High VM"
        case .fvmlib: "Fixed VM Library"
        case .noreloc: "No Relocations"
        case .protected_version_1: "Protected (Version 1)"
        case .read_only: "Read-Only"
        }
    }
}

extension SegmentCommandFlags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension SegmentCommandFlags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}
