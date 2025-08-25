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
}

extension ProgramsTrieNodeContent: TrieNodeContent {
    public static func read(
        basePointer: UnsafePointer<UInt8>,
        trieSize _: Int,
        nextOffset: inout Int
    ) -> ProgramsTrieNodeContent? {
        let (offset, ulebOffset) = basePointer
            .advanced(by: nextOffset)
            .readULEB128()

        nextOffset += ulebOffset

        return .init(offset: numericCast(offset))
    }
}
