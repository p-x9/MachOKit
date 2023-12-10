//
//  BindSpecial.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public enum BindSpecial {
    /// BIND_SPECIAL_DYLIB_SELF
    case dylib_self
    /// BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE
    case dylib_main_executable
    /// BIND_SPECIAL_DYLIB_FLAT_LOOKUP
    case dylib_flat_lookup
    /// BIND_SPECIAL_DYLIB_WEAK_LOOKUP
    case dylib_weak_lookup
}

extension BindSpecial: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case BIND_SPECIAL_DYLIB_SELF: self = .dylib_self
        case BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE: self = .dylib_main_executable
        case BIND_SPECIAL_DYLIB_FLAT_LOOKUP: self = .dylib_flat_lookup
        case BIND_SPECIAL_DYLIB_WEAK_LOOKUP: self = .dylib_weak_lookup
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .dylib_self: BIND_SPECIAL_DYLIB_SELF
        case .dylib_main_executable: BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE
        case .dylib_flat_lookup: BIND_SPECIAL_DYLIB_FLAT_LOOKUP
        case .dylib_weak_lookup: BIND_SPECIAL_DYLIB_WEAK_LOOKUP
        }
    }
}

extension BindSpecial: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dylib_self: "BIND_SPECIAL_DYLIB_SELF"
        case .dylib_main_executable: "BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE"
        case .dylib_flat_lookup: "BIND_SPECIAL_DYLIB_FLAT_LOOKUP"
        case .dylib_weak_lookup: "BIND_SPECIAL_DYLIB_WEAK_LOOKUP"
        }
    }
}
