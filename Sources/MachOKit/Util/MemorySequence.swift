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
    private let stride: Int
    private let numberOfElements: Int

    init(
        basePointer: UnsafePointer<T>,
        stride: Int,
        numberOfElements: Int
    ) {
        self.basePointer = basePointer
        self.stride = stride
        self.numberOfElements = numberOfElements
    }

    public func makeIterator() -> Iterator {
        Iterator(
            basePointer: basePointer,
            stride: stride,
            numberOfElements: numberOfElements
        )
    }
}

extension MemorySequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = T

        private let basePointer: UnsafePointer<T>
        private let stride: Int
        private let numberOfElements: Int

        private var nextIndex: Int = 0

        init(
            basePointer: UnsafePointer<T>,
            stride: Int,
            numberOfElements: Int
        ) {
            self.basePointer = basePointer
            self.stride = stride
            self.numberOfElements = numberOfElements
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfElements else { return nil }
            defer { nextIndex += 1 }
            return basePointer
                .advanced(by: nextIndex * stride)
                .pointee
        }
    }
}
