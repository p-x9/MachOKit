//
//  MemoryTrieTree.swift
//
//
//  Created by p-x9 on 2024/07/05
//  
//

import Foundation

public struct MemoryTrieTree<Content: TrieNodeContent>: TrieTreeProtocol {
    public let basePointer: UnsafeRawPointer
    public let size: Int

    @_spi(Support)
    public init(basePointer: UnsafeRawPointer, size: Int) {
        self.basePointer = basePointer
        self.size = size
    }
}

extension MemoryTrieTree {
    public func element(atOffset offset: Int) -> TrieNode<Content>? {
        var nextOffset: Int = offset
        return .readNext(
            basePointer: basePointer.assumingMemoryBound(to: UInt8.self),
            trieSize: size,
            nextOffset: &nextOffset
        )
    }
}

extension MemoryTrieTree: Sequence {
    public typealias Element = TrieNode<Content>

    public func makeIterator() -> Iterator {
        .init(basePointer: basePointer, size: size)
    }
}

extension MemoryTrieTree {
    public struct Iterator: IteratorProtocol {
        public let basePointer: UnsafeRawPointer
        public let size: Int

        internal var nextOffset: Int = 0

        @_spi(Support)
        public init(basePointer: UnsafeRawPointer, size: Int) {
            self.basePointer = basePointer
            self.size = size
        }

        public mutating func next() -> Element? {
            guard nextOffset < size else { return nil }

            return .readNext(
                basePointer: basePointer.assumingMemoryBound(to: UInt8.self),
                trieSize: size,
                nextOffset: &nextOffset
            )
        }
    }
}
