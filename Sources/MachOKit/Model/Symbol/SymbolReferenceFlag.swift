//
//  SymbolReferenceFlag.swift
//
//
//  Created by p-x9 on 2023/12/08.
//  
//

import Foundation

public enum SymbolReferenceFlag {
    /// REFERENCE_FLAG_UNDEFINED_NON_LAZY
    case undefined_non_lazy
    /// REFERENCE_FLAG_UNDEFINED_LAZY
    case undefined_lazy
    /// REFERENCE_FLAG_DEFINED
    case defined
    /// REFERENCE_FLAG_PRIVATE_DEFINED
    case private_defined
    /// REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY
    case private_undefined_non_lazy
    /// REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY
    case private_undefined_lazy
}

extension SymbolReferenceFlag: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(REFERENCE_FLAG_UNDEFINED_NON_LAZY): self = .undefined_non_lazy
        case RawValue(REFERENCE_FLAG_UNDEFINED_LAZY): self = .undefined_lazy
        case RawValue(REFERENCE_FLAG_DEFINED): self = .defined
        case RawValue(REFERENCE_FLAG_PRIVATE_DEFINED): self = .private_defined
        case RawValue(REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY): self = .private_undefined_non_lazy
        case RawValue(REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY): self = .private_undefined_lazy
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .undefined_non_lazy: RawValue(REFERENCE_FLAG_UNDEFINED_NON_LAZY)
        case .undefined_lazy: RawValue(REFERENCE_FLAG_UNDEFINED_LAZY)
        case .defined: RawValue(REFERENCE_FLAG_DEFINED)
        case .private_defined: RawValue(REFERENCE_FLAG_PRIVATE_DEFINED)
        case .private_undefined_non_lazy: RawValue(REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY)
        case .private_undefined_lazy: RawValue(REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY)
        }
    }
}

extension SymbolReferenceFlag: CustomStringConvertible {
    public var description: String {
        switch self {
        case .undefined_non_lazy: "REFERENCE_FLAG_UNDEFINED_NON_LAZY"
        case .undefined_lazy: "REFERENCE_FLAG_UNDEFINED_LAZY"
        case .defined: "REFERENCE_FLAG_DEFINED"
        case .private_defined: "REFERENCE_FLAG_PRIVATE_DEFINED"
        case .private_undefined_non_lazy: "REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY"
        case .private_undefined_lazy: "REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY"
        }
    }
}
