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

    private let basePointer: UnsafePointer<T>
    private let numberOfElements: Int

    init(
        basePointer: UnsafePointer<T>,
        numberOfElements: Int
    ) {
        self.basePointer = basePointer
        self.numberOfElements = numberOfElements
    }

    public func makeIterator() -> Iterator {
        Iterator(
            basePointer: basePointer,
            numberOfElements: numberOfElements
        )
    }
}

extension MemorySequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = T

        private let basePointer: UnsafePointer<T>
        private let numberOfElements: Int

        private var nextIndex: Int = 0

        init(
            basePointer: UnsafePointer<T>,
            numberOfElements: Int
        ) {
            self.basePointer = basePointer
            self.numberOfElements = numberOfElements
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfElements else { return nil }
            defer { nextIndex += 1 }
            return basePointer
                .advanced(by: nextIndex)
                .pointee
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
        return basePointer.advanced(by: position).pointee
    }
}

extension MemorySequence: RandomAccessCollection {}
