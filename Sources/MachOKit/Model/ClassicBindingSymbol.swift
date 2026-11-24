//
//  ClassicBindingSymbol.swift
//  MachOKit
//
//  Created by p-x9 on 2025/03/04
//
//

import Foundation

public struct ClassicBindingSymbol: Sendable {
    public let type: ClassicBindType
    public let address: UInt
    public let symbolIndex: Int
    public let addend: Int

    /// Creates a classic binding from its type, address, symbol index, and addend.
    public init(type: ClassicBindType, address: UInt, symbolIndex: Int, addend: Int) {
        self.type = type
        self.address = address
        self.symbolIndex = symbolIndex
        self.addend = addend
    }
}
