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
        public let data: Data
        public let functionStartsOffset: Int
        public let functionStartsSize: Int
        public let functionStartBase: UInt

        public func makeIterator() -> Iterator {
            .init(
                data: data,
                functionStartBase: functionStartBase
            )
        }
    }
}

extension MachOFile.FunctionStarts {
    init(
        machO: MachOFile,
        functionStartsOffset: Int,
        functionStartsSize: Int,
        functionStartBase: UInt
    ) {
        let offset = machO.headerStartOffset + functionStartsOffset
        let data = try! machO.fileHandle.readData(
            offset: offset,
            length: functionStartsSize
        )

        self.init(
            data: data,
            functionStartsOffset: functionStartsOffset,
            functionStartsSize: functionStartsSize,
            functionStartBase: functionStartBase
        )
    }

    init(
        machO: MachOFile,
        functionStarts: linkedit_data_command,
        text: SegmentCommand64
    ) {
        self.init(
            machO: machO,
            functionStartsOffset: numericCast(functionStarts.dataoff),
            functionStartsSize: numericCast(functionStarts.datasize),
            functionStartBase: numericCast(text.vmaddr)
        )
    }

    init(
        machO: MachOFile,
        functionStarts: linkedit_data_command,
        text: SegmentCommand
    ) {
        self.init(
            machO: machO,
            functionStartsOffset: numericCast(functionStarts.dataoff),
            functionStartsSize: numericCast(functionStarts.datasize),
            functionStartBase: numericCast(text.vmaddr)
        )
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
