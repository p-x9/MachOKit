//
//  ProgramsTrieNodeContent.swift
//
//
//  Created by p-x9 on 2024/07/09
//  
//

import Foundation

public typealias ProgramsTrieEntry = TrieNode<ProgramsTrieNodeContent>

public struct ProgramsTrieNodeContent: Sendable {
    public let offset: UInt32

    /// Creates program trie content with the given offset.
    public init(offset: UInt32) {
        self.offset = offset
    }
}

extension ProgramsTrieNodeContent: TrieNodeContent {
    public static func read(
        basePointer: UnsafePointer<UInt8>,
        trieSize: Int,
        nextOffset: inout Int
    ) -> ProgramsTrieNodeContent? {
        guard let (offset, ulebOffset) = basePointer
            .advanced(by: nextOffset)
            .readULEB128(maxSize: trieSize - nextOffset) else {
            return nil
        }

        nextOffset += ulebOffset

        guard let offset = UInt32(exactly: offset) else { return nil }

        return .init(offset: offset)
    }
}
