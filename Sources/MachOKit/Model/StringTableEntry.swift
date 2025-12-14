//
//  StringTableEntry.swift
//
//
//  Created by p-x9 on 2023/12/04.
//
//

import Foundation

public struct StringTableEntry: Codable, Equatable, Sendable {
    public let string: String
    ///  Offset from the beginning of the string table
    public let offset: Int
}
