//
//  RelocationLength.swift
//
//
//  Created by p-x9 on 2024/01/10.
//
//

import Foundation

public enum RelocationLength: UInt32, Sendable {
    case byte
    case word
    case long
    case quad
}

extension RelocationLength: CustomStringConvertible {
    public var description: String {
        switch self {
        case .byte: "byte"
        case .word: "word"
        case .long: "long"
        case .quad: "quad"
        }
    }
}
