import Foundation
import MachOKit

extension RelocationLength: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .byte: "Byte (8-bit)"
        case .word: "Word (16-bit)"
        case .long: "Long (32-bit)"
        case .quad: "Quad (64-bit)"
        }
    }
}
