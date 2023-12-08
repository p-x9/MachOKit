//
//  BindType.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public enum BindType {
    case pointer
    case text_absolute32
    case text_pcrel32
}

extension BindType: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case BIND_TYPE_POINTER: self = .pointer
        case BIND_TYPE_TEXT_ABSOLUTE32: self = .text_absolute32
        case BIND_TYPE_TEXT_PCREL32: self = .text_pcrel32
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .pointer: BIND_TYPE_POINTER
        case .text_absolute32: BIND_TYPE_TEXT_ABSOLUTE32
        case .text_pcrel32: BIND_TYPE_TEXT_PCREL32
        }
    }
}

extension BindType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pointer: "BIND_TYPE_POINTER"
        case .text_absolute32: "BIND_TYPE_TEXT_ABSOLUTE32"
        case .text_pcrel32: "BIND_TYPE_TEXT_PCREL32"
        }
    }
}
