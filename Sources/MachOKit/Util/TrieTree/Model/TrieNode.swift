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
    public struct Child: Sendable {
        public let label: String
        public let offset: UInt

        /// Creates a child reference. The offset is relative to the start of the trie.
        public init(label: String, offset: UInt) {
            self.label = label
            self.offset = offset
        }
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
    /// Reads the node located at `nextOffset`.
    ///
    /// All reads are bounded by `trieSize`.
    /// Returns `nil` when the node is malformed, i.e. when a ULEB128 value, the terminal
    /// payload, a child label or a child offset does not stay inside the trie.
    public static func readNext(
        basePointer: UnsafePointer<UInt8>,
        trieSize: Int,
        nextOffset: inout Int
    ) -> Self? {
        guard nextOffset >= 0, nextOffset < trieSize else { return nil }

        guard let (terminalSize, terminalBytes) = basePointer
            .advanced(by: nextOffset)
            .readULEB128(maxSize: trieSize - nextOffset) else {
            return nil
        }
        nextOffset += terminalBytes

        guard terminalSize <= UInt(trieSize - nextOffset) else { return nil }

        var entry = TrieNode(
            offset: nextOffset - terminalBytes,
            terminalSize: terminalSize,
            content: nil,
            children: []
        )

        var childrenOffset = nextOffset + Int(terminalSize)

        if terminalSize != 0 {
            guard let content = Content.read(
                basePointer: basePointer,
                trieSize: trieSize,
                nextOffset: &nextOffset
            ), nextOffset <= childrenOffset else {
                return nil
            }
            entry.content = content
        }

        guard childrenOffset < trieSize else { return entry }

        let numberOfChildren = basePointer
            .advanced(by: childrenOffset)
            .pointee
        childrenOffset += MemoryLayout<UInt8>.size

        for _ in 0..<numberOfChildren {
            guard let (string, stringOffset) = basePointer
                .advanced(by: childrenOffset)
                .readString(maxSize: trieSize - childrenOffset) else {
                return nil
            }
            childrenOffset += stringOffset

            guard let (value, ulebOffset) = basePointer
                .advanced(by: childrenOffset)
                .readULEB128(maxSize: trieSize - childrenOffset),
                  value < UInt(trieSize) else {
                return nil
            }
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

extension TrieNode: Sendable where Content: Sendable {}
