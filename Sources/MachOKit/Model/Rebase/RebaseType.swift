//
//  RebaseType.swift
//  
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public enum RebaseType {
    /// REBASE_TYPE_POINTER
    case pointer
    /// REBASE_TYPE_TEXT_ABSOLUTE32
    case text_absolute32
    /// REBASE_TYPE_TEXT_PCREL32
    case text_pcrel32
}

extension RebaseType: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case REBASE_TYPE_POINTER: self = .pointer
        case REBASE_TYPE_TEXT_ABSOLUTE32: self = .text_absolute32
        case REBASE_TYPE_TEXT_PCREL32: self = .text_pcrel32
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .pointer: REBASE_TYPE_POINTER
        case .text_absolute32: REBASE_TYPE_TEXT_ABSOLUTE32
        case .text_pcrel32: REBASE_TYPE_TEXT_PCREL32
        }
    }
}

extension RebaseType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pointer: "REBASE_TYPE_POINTER"
        case .text_absolute32: "REBASE_TYPE_TEXT_ABSOLUTE32"
        case .text_pcrel32: "REBASE_TYPE_TEXT_PCREL32"
        }
    }
}
