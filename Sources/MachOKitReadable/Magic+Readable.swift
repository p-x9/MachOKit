import Foundation
import MachOKit

extension Magic: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .magic: "Mach-O 32-bit"
        case .cigam: "Mach-O 32-bit (Byte-Swapped)"
        case .magic64: "Mach-O 64-bit"
        case .cigam64: "Mach-O 64-bit (Byte-Swapped)"
        case .fatMagic: "Fat Binary"
        case .fatCigam: "Fat Binary (Byte-Swapped)"
        case .fatMagic64: "Fat Binary 64-bit"
        case .fatCigam64: "Fat Binary 64-bit (Byte-Swapped)"
        }
    }
}
