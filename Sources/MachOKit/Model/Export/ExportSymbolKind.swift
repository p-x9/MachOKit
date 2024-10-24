//
//  ExportSymbolKind.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public enum ExportSymbolKind {
    /// EXPORT_SYMBOL_FLAGS_KIND_REGULAR
    case regular
    /// EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL
    case thread_local
    /// EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE
    case absolute
}

extension ExportSymbolKind: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case EXPORT_SYMBOL_FLAGS_KIND_REGULAR: self = .regular
        case EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL: self = .thread_local
        case EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE: self = .absolute
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .regular: EXPORT_SYMBOL_FLAGS_KIND_REGULAR
        case .thread_local: EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL
        case .absolute: EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE
        }
    }
}

extension ExportSymbolKind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .regular: "EXPORT_SYMBOL_FLAGS_KIND_REGULAR"
        case .thread_local: "EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL"
        case .absolute: "EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE"
        }
    }
}
