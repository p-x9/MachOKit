//
//  ProgramOffset.swift
//
//
//  Created by p-x9 on 2024/07/09
//  
//

import Foundation

public struct ProgramOffset: Sendable {
    public let name: String
    public let offset: UInt32

    /// Creates a program name and offset pair.
    public init(name: String, offset: UInt32) {
        self.name = name
        self.offset = offset
    }
}
