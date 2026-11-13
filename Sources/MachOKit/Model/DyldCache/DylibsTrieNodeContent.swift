//
//  DylibsTrieNodeContent.swift
//  
//
//  Created by p-x9 on 2024/07/07
//  
//

import Foundation

public typealias DylibsTrieEntry = TrieNode<DylibsTrieNodeContent>

public struct DylibsTrieNodeContent: Sendable {
    public let index: UInt32

    /// Creates dylib trie content with the given dylib index.
    public init(index: UInt32) {
        self.index = index
    }
}

extension DylibsTrieNodeContent: TrieNodeContent {
    public static func read(
        basePointer: UnsafePointer<UInt8>,
        trieSize: Int,
        nextOffset: inout Int
    ) -> DylibsTrieNodeContent? {
        guard let (index, ulebOffset) = basePointer
            .advanced(by: nextOffset)
            .readULEB128(maxSize: trieSize - nextOffset) else {
            return nil
        }

        nextOffset += ulebOffset

        guard let index = UInt32(exactly: index) else { return nil }

        return .init(index: index)
    }
}
