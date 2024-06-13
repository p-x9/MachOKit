//
//  SymbolFlags.swift
//  
//
//  Created by p-x9 on 2023/12/08.
//  
//

import Foundation

public struct SymbolFlags: BitFlags, @unchecked Sendable {
    public typealias RawValue = Int32

    public let rawValue: RawValue

    public var stab: Stab? {
        guard rawValue & N_STAB != 0 else { return nil }
        return .init(rawValue: rawValue)
    }

    public var type: SymbolType? {
        let rawValue = (rawValue & N_TYPE)
        return .init(rawValue: rawValue)
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension SymbolFlags {
    /// N_PEXT
    public static let pext = SymbolFlags(
        rawValue: Bit.pext.rawValue
    )
    /// N_EXT
    public static let ext = SymbolFlags(
        rawValue: Bit.ext.rawValue
    )
}

extension SymbolFlags {
    public enum Bit: CaseIterable {
        /// N_PEXT
        /// private external symbol bit
        case pext
        /// N_EXT
        /// external symbol bit, set for external symbols
        case ext
    }
}

extension SymbolFlags.Bit: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case N_PEXT: self = .pext
        case N_EXT: self = .ext
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .pext: N_PEXT
        case .ext: N_EXT
        }
    }
}

extension SymbolFlags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pext: "N_PEXT"
        case .ext: "N_EXT"
        }
    }
}
