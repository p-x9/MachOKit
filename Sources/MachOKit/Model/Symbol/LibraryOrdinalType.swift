//
//  LibraryOrdinalType.swift
//  
//
//  Created by p-x9 on 2023/12/08.
//  
//

import Foundation

public enum LibraryOrdinalType {
    /// SELF_LIBRARY_ORDINAL
    case `self`
    /// DYNAMIC_LOOKUP_ORDINAL
    case dynamic_lookup_ordinal
    /// EXECUTABLE_ORDINAL
    case executable_ordinal
}

extension LibraryOrdinalType: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(SELF_LIBRARY_ORDINAL): self = .`self`
        case RawValue(DYNAMIC_LOOKUP_ORDINAL): self = .dynamic_lookup_ordinal
        case RawValue(EXECUTABLE_ORDINAL): self = .executable_ordinal
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .`self`: RawValue(SELF_LIBRARY_ORDINAL)
        case .dynamic_lookup_ordinal: RawValue(DYNAMIC_LOOKUP_ORDINAL)
        case .executable_ordinal: RawValue(EXECUTABLE_ORDINAL)
        }
    }
}

extension LibraryOrdinalType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .self: "SELF_LIBRARY_ORDINAL"
        case .dynamic_lookup_ordinal: "DYNAMIC_LOOKUP_ORDINAL"
        case .executable_ordinal: "EXECUTABLE_ORDINAL"
        }
    }
}
