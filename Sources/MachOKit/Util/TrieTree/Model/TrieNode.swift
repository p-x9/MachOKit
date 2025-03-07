//
//  TrieNode.swift
//
//
//  Created by p-x9 on 2024/07/05
//
//

import Foundation

@dynamicMemberLookup
public struct TrieNode<Content: TrieNodeContent> {
    public struct Child {
        public let label: String
        public let offset: UInt
    }

    public let offset: Int
    public let terminalSize: UInt

    // Content
    public var content: Content?

    public var children: [Child]

    @_spi(Support)
    public init(
        offset: Int,
        terminalSize: UInt,
        content: Content?,
        children: [Child]
    ) {
        self.offset = offset
        self.terminalSize = terminalSize
        self.content = content
        self.children = children
    }
}

extension TrieNode {
    public var isTerminal: Bool {
        terminalSize != 0
    }
}

extension TrieNode {
    public static func readNext(
        basePointer: UnsafePointer<UInt8>,
        trieSize: Int,
        nextOffset: inout Int
    ) -> Self? {
        guard nextOffset < trieSize else { return nil }

        let (terminalSize, terminalBytes) = basePointer
            .advanced(by: nextOffset)
            .readULEB128()
        nextOffset += terminalBytes

        var entry = TrieNode(
            offset: nextOffset - terminalBytes,
            terminalSize: terminalSize,
            content: nil,
            children: []
        )

        var childrenOffset = nextOffset + Int(terminalSize)

        if terminalSize != 0 {
            entry.content = .read(
                basePointer: basePointer,
                trieSize: trieSize,
                nextOffset: &nextOffset
            )
        }

        guard childrenOffset < trieSize else { return entry }

        let numberOfChildren = basePointer
            .advanced(by: childrenOffset)
            .pointee
        childrenOffset += MemoryLayout<UInt8>.size

        for _ in 0..<numberOfChildren {
            let (string, stringOffset) = basePointer
                .advanced(by: childrenOffset)
                .readString()
            childrenOffset += stringOffset

            let (value, ulebOffset) = basePointer
                .advanced(by: childrenOffset)
                .readULEB128()
            childrenOffset += ulebOffset

            let child = TrieNode.Child(label: string, offset: value)
            entry.children.append(child)
        }

        nextOffset = childrenOffset

        return entry
    }
}

extension TrieNode {
    public subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value?>) -> Value? {
        content?[keyPath: keyPath]
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value? {
        content?[keyPath: keyPath]
    }
}
