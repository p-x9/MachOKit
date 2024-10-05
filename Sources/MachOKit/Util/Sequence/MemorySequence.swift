//
//  MemorySequence.swift
//  
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public struct MemorySequence<T>: Sequence {
    public typealias Element = T

    private let basePointer: UnsafeRawPointer
    private let entrySize: Int
    private let numberOfElements: Int

    @_spi(Support)
    public init(
        basePointer: UnsafePointer<T>,
        numberOfElements: Int
    ) {
        self.basePointer = .init(basePointer)
        self.entrySize = MemoryLayout<Element>.size
        self.numberOfElements = numberOfElements
    }

    @_spi(Support)
    public init(
        basePointer: UnsafePointer<T>,
        entrySize: Int,
        numberOfElements: Int
    ) {
        self.basePointer = .init(basePointer)
        self.entrySize = entrySize
        self.numberOfElements = numberOfElements
    }

    public func makeIterator() -> Iterator {
        Iterator(
            basePointer: basePointer,
            entrySize: entrySize,
            numberOfElements: numberOfElements
        )
    }
}

extension MemorySequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = T

        private let basePointer: UnsafeRawPointer
        private let entrySize: Int
        private let numberOfElements: Int

        private var nextIndex: Int = 0

        init(
            basePointer: UnsafeRawPointer,
            entrySize: Int,
            numberOfElements: Int
        ) {
            self.basePointer = basePointer
            self.entrySize = entrySize
            self.numberOfElements = numberOfElements
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfElements else { return nil }
            defer { nextIndex += 1 }
            return basePointer
                .advanced(by: nextIndex * entrySize)
                .load(as: Element.self)
        }
    }
}

extension MemorySequence: Collection {
    public typealias Index = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { numberOfElements }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> Element {
        precondition(position >= 0)
        precondition(position < endIndex)
        return basePointer
            .advanced(by: position * entrySize)
            .load(as: Element.self)
    }
}

extension MemorySequence: RandomAccessCollection {}
