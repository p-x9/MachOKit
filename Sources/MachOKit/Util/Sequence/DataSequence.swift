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
    private let numberOfElements: Int

    init(
        data: Data,
        numberOfElements: Int
    ) {
        self.data = data
        self.numberOfElements = numberOfElements
    }

    public func makeIterator() -> Iterator {
        Iterator(
            data: data,
            numberOfElements: numberOfElements
        )
    }
}

extension DataSequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = T

        private let data: Data
        private let numberOfElements: Int

        private var nextIndex: Int = 0
        private var nextOffset: Int = 0

        init(
            data: Data,
            numberOfElements: Int
        ) {
            self.data = data
            self.numberOfElements = numberOfElements
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfElements else { return nil }
            guard nextOffset < data.count else { return nil }

            defer {
                nextIndex += 1
                nextOffset += MemoryLayout<Element>.size
            }

            return data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return nil }
                return baseAddress.advanced(by: nextOffset).load(as: Element.self)
            }
        }
    }
}
