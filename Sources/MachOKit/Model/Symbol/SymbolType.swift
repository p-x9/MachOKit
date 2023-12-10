//
//  SymbolType.swift
//
//
//  Created by p-x9 on 2023/12/08.
//  
//

import Foundation

public enum SymbolType {
    /// N_UNDF
    /// undefined, n_sect == NO_SECT
    case undf

    /// N_ABS
    /// absolute, n_sect == NO_SECT
    case abs

    /// N_SECT
    /// defined in section number n_sect
    case sect

    /// N_PBUD
    /// prebound undefined (defined in a dylib)
    case pbud

    /// N_INDR
    /// indirect
    case indr
}

extension SymbolType: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(N_UNDF): self = .undf
        case RawValue(N_ABS): self = .abs
        case RawValue(N_SECT): self = .sect
        case RawValue(N_PBUD): self = .pbud
        case RawValue(N_INDR): self = .indr
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .undf: RawValue(N_UNDF)
        case .abs: RawValue(N_ABS)
        case .sect: RawValue(N_SECT)
        case .pbud: RawValue(N_PBUD)
        case .indr: RawValue(N_PBUD)
        }
    }
}

extension SymbolType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .undf: "N_UNDF"
        case .abs: "N_ABS"
        case .sect: "N_SECT"
        case .pbud: "N_PBUD"
        case .indr: "N_PBUD"
        }
    }
}
