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
