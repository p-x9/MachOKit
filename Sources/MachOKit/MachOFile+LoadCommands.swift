//
//  MachOFile+LoadCommands.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

extension MachOFile {
    public struct LoadCommands: Sequence {
        public let data: Data
        public let numberOfCommands: Int
        public let isSwapped: Bool

        public func makeIterator() -> Iterator {
            Iterator(
                data: data,
                numberOfCommands: numberOfCommands,
                isSwapped: isSwapped
            )
        }
    }
}

extension MachOFile.LoadCommands {
    public struct Iterator: IteratorProtocol {
        public typealias Element = LoadCommand

        public let data: Data
        public let numberOfCommands: Int
        public let isSwapped: Bool

        private var nextOffset: Int = 0
        private var nextIndex: Int = 0

        public init(
            data: Data,
            numberOfCommands: Int,
            isSwapped: Bool
        ) {
            self.data = data
            self.numberOfCommands = numberOfCommands
            self.isSwapped = isSwapped
        }

        public mutating func next() -> Element? {
            guard nextOffset < data.count else {
                return nil
            }
            guard nextIndex < numberOfCommands else {
                return nil
            }

            return data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return nil }

                let ptr = UnsafeMutableRawPointer(mutating: baseAddress.advanced(by: nextOffset))
                    .assumingMemoryBound(to: load_command.self)

                var next = LoadCommand.convert(UnsafePointer(ptr), offset: nextOffset)

                if isSwapped {
                    next = next?.swapped()
                }

                nextOffset += Int(isSwapped ? ptr.pointee.cmdsize.byteSwapped : ptr.pointee.cmdsize)
                nextIndex += 1

                return next
            }
        }
    }
}

extension MachOFile.LoadCommands: LoadCommandsProtocol {}
