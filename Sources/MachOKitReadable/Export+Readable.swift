import Foundation
import MachOKit

extension ExportSymbolKind: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .regular: "Regular"
        case .thread_local: "Thread-Local"
        case .absolute: "Absolute"
        }
    }
}

extension ExportSymbolFlags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .weak_definition: "Weak Definition"
        case .reexport: "Re-export"
        case .stub_and_resolver: "Stub and Resolver"
        case .static_resolver: "Static Resolver"
        case .function_variant: "Function Variant"
        }
    }
}

extension ExportSymbolFlags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension ExportSymbolFlags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}
