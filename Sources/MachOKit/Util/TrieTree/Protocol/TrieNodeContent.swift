//
//  TrieNodeContent.swift
//  
//
//  Created by p-x9 on 2024/07/05
//  
//

import Foundation

public protocol TrieNodeContent {
    /// Reads the terminal payload of a node located at `nextOffset`.
    ///
    /// Implementations must not read at or beyond `trieSize` and should return `nil`
    /// when the payload is malformed. ``TrieNode`` treats `nil` as a malformed node.
    static func read(
        basePointer: UnsafePointer<UInt8>,
        trieSize: Int,
        nextOffset: inout Int
    ) -> Self?
}
