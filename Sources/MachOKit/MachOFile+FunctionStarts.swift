//
//  MachOFile+FunctionStarts.swift
//
//
//  Created by p-x9 on 2024/01/07.
//  
//

import Foundation

extension MachOFile {
    public struct FunctionStarts: Sequence {
        let machO: MachOFile
        public let functionStartsOffset: Int
        public let functionStartsSize: Int
        public let functionStartBase: UInt

        public func makeIterator() -> Iterator {
            let offset = machO.headerStartOffset + functionStartsOffset
            machO.fileHandle.seek(
                toFileOffset: UInt64(offset)
            )

            let data = machO.fileHandle.readData(ofLength: functionStartsSize)

            return .init(
                data: data,
                functionStartBase: functionStartBase
            )
        }
    }
}

extension MachOFile.FunctionStarts {
    public struct Iterator: IteratorProtocol {
        public typealias Element = FunctionStart

        private let data: Data
        private var nextOffset: Int = 0
        private var lastFunctionOffset: UInt = 0

        init(
            data: Data,
            functionStartBase: UInt
        ) {
            self.data = data
            self.lastFunctionOffset = functionStartBase
        }

        public mutating func next() -> FunctionStart? {
            guard nextOffset < data.count else { return nil }

            return data.withUnsafeBytes {
                guard let basePointer = $0.baseAddress else { return nil }
                let next = FunctionStart.readNext(
                    basePointer: basePointer
                        .assumingMemoryBound(to: UInt8.self),
                    functionStartsSize: data.count,
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
}
