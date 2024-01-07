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
    init?(
        functionStarts: linkedit_data_command,
        linkedit: SegmentCommand64,
        text: SegmentCommand64,
        vmaddrSlide: Int
    ) {
        var linkeditStart = vmaddrSlide
        linkeditStart += numericCast(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        guard let linkeditStartPtr = UnsafeRawPointer(bitPattern: linkeditStart) else {
            return nil
        }

        let start = linkeditStartPtr
            .advanced(by: numericCast(functionStarts.dataoff))
            .assumingMemoryBound(to: UInt8.self)
        let size: Int = numericCast(functionStarts.datasize)

        self.init(
            basePointer: start,
            functionStartsSize: size,
            functionStartBase: numericCast(text.vmaddr)
        )
    }

    init?(
        functionStarts: linkedit_data_command,
        linkedit: SegmentCommand,
        text: SegmentCommand,
        vmaddrSlide: Int
    ) {
        var linkeditStart = vmaddrSlide
        linkeditStart += numericCast(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        guard let linkeditStartPtr = UnsafeRawPointer(bitPattern: linkeditStart) else {
            return nil
        }

        let start = linkeditStartPtr
            .advanced(by: numericCast(functionStarts.dataoff))
            .assumingMemoryBound(to: UInt8.self)
        let size: Int = numericCast(functionStarts.datasize)

        self.init(
            basePointer: start,
            functionStartsSize: size,
            functionStartBase: numericCast(text.vmaddr)
        )
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
