//
//  DataSequence.swift
//
//
//  Created by p-x9 on 2023/12/06.
//  
//

import Foundation

public struct DataSequence<T>: Sequence {
    public typealias Element = T

    private let data: Data
    private let entrySize: Int
    private let numberOfElements: Int

    @_spi(Support)
    public init(
        data: Data,
        numberOfElements: Int
    ) {
        self.data = data
        self.entrySize = MemoryLayout<Element>.size
        self.numberOfElements = numberOfElements
    }

    @_spi(Support)
    public init(
        data: Data,
        entrySize: Int
    ) {
        self.data = data
        self.entrySize = entrySize
        self.numberOfElements = data.count / entrySize
    }

    public func makeIterator() -> Iterator {
        Iterator(
            data: data, 
            entrySize: entrySize,
            numberOfElements: numberOfElements
        )
    }
}

extension DataSequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = T

        private let data: Data
        private let entrySize: Int
        private let numberOfElements: Int

        private var nextIndex: Int = 0
        private var nextOffset: Int = 0

        init(
            data: Data,
            entrySize: Int,
            numberOfElements: Int
        ) {
            self.data = data
            self.entrySize = entrySize
            self.numberOfElements = numberOfElements
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfElements else { return nil }
            guard nextOffset < data.count else { return nil }

            defer {
                nextIndex += 1
                nextOffset += entrySize
            }

            return data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return nil }
                return baseAddress.advanced(by: nextOffset).load(as: Element.self)
            }
        }
    }
}

extension DataSequence: Collection {
    public typealias Index = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { numberOfElements }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> Element {
        precondition(position >= 0)
        precondition(position < endIndex)
        return data.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else { fatalError() }
            return baseAddress
                .advanced(by: position * entrySize)
                .load(as: Element.self)
        }
    }
}

extension DataSequence: RandomAccessCollection {}
