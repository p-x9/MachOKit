//
//  CodeSignHashType.swift
//
//
//  Created by p-x9 on 2024/03/03.
//
//

import Foundation
import MachOKitC

public enum CodeSignHashType: Sendable {
    case sha1
    case sha256
    case sha256_truncated
    case sha384
}

extension CodeSignHashType: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: UInt32) {
        switch rawValue {
        case CS_HASHTYPE_SHA1: self = .sha1
        case CS_HASHTYPE_SHA256: self = .sha256
        case CS_HASHTYPE_SHA256_TRUNCATED: self = .sha256_truncated
        case CS_HASHTYPE_SHA384: self = .sha384
        default:
            return nil
        }
    }

    public var rawValue: UInt32 {
        switch self {
        case .sha1: CS_HASHTYPE_SHA1
        case .sha256: CS_HASHTYPE_SHA256
        case .sha256_truncated: CS_HASHTYPE_SHA256_TRUNCATED
        case .sha384: CS_HASHTYPE_SHA384
        }
    }
}

extension CodeSignHashType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sha1: "CS_HASHTYPE_SHA1"
        case .sha256: "CS_HASHTYPE_SHA256"
        case .sha256_truncated: "CS_HASHTYPE_SHA256_TRUNCATED"
        case .sha384: "CS_HASHTYPE_SHA384"
        }
    }
}

extension CodeSignHashType {
    package var priority: Int {
        switch self {
        case .sha1: 0
        case .sha256_truncated: 1
        case .sha256: 2
        case .sha384: 3
        }
    }
}
