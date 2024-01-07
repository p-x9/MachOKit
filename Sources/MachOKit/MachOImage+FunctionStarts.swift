//
//  MachOImage+FunctionStarts.swift
//
//
//  Created by p-x9 on 2024/01/07.
//  
//

import Foundation

extension MachOImage {
    public struct FunctionStarts: Sequence {
        public let basePointer: UnsafePointer<UInt8>
        public let functionStartsSize: Int
        public let functionStartBase: UInt

        public func makeIterator() -> Iterator {
            .init(
                basePointer: basePointer,
                functionStartsSize: functionStartsSize,
                functionStartBase: functionStartBase
            )
        }
    }
}

extension MachOImage.FunctionStarts {
    public struct Iterator: IteratorProtocol {
        public typealias Element = FunctionStart

        private let basePointer: UnsafePointer<UInt8>
        private let functionStartsSize: Int
        private let functionStartBase: UInt

        private var nextOffset: Int = 0
        private var lastFunctionOffset: UInt = 0

        init(
            basePointer: UnsafePointer<UInt8>,
            functionStartsSize: Int,
            functionStartBase: UInt
        ) {
            self.basePointer = basePointer
            self.functionStartsSize = functionStartsSize
            self.functionStartBase = functionStartBase
            self.lastFunctionOffset = functionStartBase
        }

        public mutating func next() -> FunctionStart? {
            let next = FunctionStart.readNext(
                basePointer: basePointer,
                functionStartsSize: functionStartsSize,
                lastFunctionOffset: lastFunctionOffset,
                nextOffset: &nextOffset
            )
            if let next {
                lastFunctionOffset = next.offset
            }

            return next
        }
    }
}
