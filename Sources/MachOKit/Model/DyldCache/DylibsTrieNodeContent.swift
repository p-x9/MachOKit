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
}

extension DylibsTrieNodeContent: TrieNodeContent {
    public static func read(
        basePointer: UnsafePointer<UInt8>,
        trieSize _: Int,
        nextOffset: inout Int
    ) -> DylibsTrieNodeContent? {
        let (index, ulebOffset) = basePointer
            .advanced(by: nextOffset)
            .readULEB128()

        nextOffset += ulebOffset

        return .init(index: numericCast(index))
    }
}
