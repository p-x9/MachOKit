//
//  TrieNodeContent.swift
//  
//
//  Created by p-x9 on 2024/07/05
//  
//

import Foundation

public protocol TrieNodeContent {
    /// Reads the terminal payload of a node, starting at `nextOffset`.
    ///
    /// - Parameters:
    ///   - basePointer: Start of the trie.
    ///   - maxOffset: Exclusive upper bound for reads, relative to `basePointer`.
    ///   - nextOffset: Read position, advanced past the content on success.
    static func read(
        basePointer: UnsafePointer<UInt8>,
        maxOffset: Int,
        nextOffset: inout Int
    ) -> Self?
}
