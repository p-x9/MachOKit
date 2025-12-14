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
}
