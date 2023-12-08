//
//  ExportSymbolFlags.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public struct ExportSymbolFlags: OptionSet {
    public typealias RawValue = Int32

    public var rawValue: RawValue

    public var kind: ExportSymbolKind? {
        .init(rawValue: rawValue & EXPORT_SYMBOL_FLAGS_KIND_MASK)
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension ExportSymbolFlags {
    public static let weak_definition = ExportSymbolFlags(
        rawValue: Bit.weak_definition.rawValue
    )
    public static let reexport = ExportSymbolFlags(
        rawValue: Bit.reexport.rawValue
    )
    public static let stub_and_resolver = ExportSymbolFlags(
        rawValue: Bit.stub_and_resolver.rawValue
    )
    public static let static_resolver = ExportSymbolFlags(
        rawValue: Bit.static_resolver.rawValue
    )
}

extension ExportSymbolFlags {
    public enum Bit: CaseIterable {
        case weak_definition
        case reexport
        case stub_and_resolver
        case static_resolver
    }
}

extension ExportSymbolFlags.Bit: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION): self = .weak_definition
        case RawValue(EXPORT_SYMBOL_FLAGS_REEXPORT): self = .reexport
        case RawValue(EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER): self = .stub_and_resolver
        case RawValue(EXPORT_SYMBOL_FLAGS_STATIC_RESOLVER): self = .static_resolver
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .weak_definition: RawValue(EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION)
        case .reexport: RawValue(EXPORT_SYMBOL_FLAGS_REEXPORT)
        case .stub_and_resolver: RawValue(EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER)
        case .static_resolver: RawValue(EXPORT_SYMBOL_FLAGS_STATIC_RESOLVER)
        }
    }
}

extension ExportSymbolFlags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .weak_definition: "EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION"
        case .reexport: "EXPORT_SYMBOL_FLAGS_REEXPORT"
        case .stub_and_resolver: "EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER"
        case .static_resolver: "EXPORT_SYMBOL_FLAGS_STATIC_RESOLVER"
        }
    }
}

extension ExportSymbolFlags {
    public var bits: [Bit] {
        ExportSymbolFlags.Bit.allCases
            .lazy
            .filter {
                contains(.init(rawValue: $0.rawValue))
            }
    }
}
