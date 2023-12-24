//
//  MachO+LoadCommands.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

extension MachO {
    public struct LoadCommands: Sequence {
        public let start: UnsafeRawPointer
        public let numberOfCommands: Int

        public func makeIterator() -> Iterator {
            Iterator(
                start: start,
                numberOfCommands: numberOfCommands
            )
        }
    }
}

extension MachO.LoadCommands {
    public struct Iterator: IteratorProtocol {
        public typealias Element = LoadCommand

        public let start: UnsafeRawPointer
        public let numberOfCommands: Int

        private var nextOffset: Int = 0
        private var nextIndex: Int = 0

        public init(
            start: UnsafeRawPointer,
            numberOfCommands: Int
        ) {
            self.start = start
            self.numberOfCommands = numberOfCommands
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfCommands else {
                return nil
            }
            let ptr = start.advanced(by: nextOffset)
                .assumingMemoryBound(to: load_command.self)

            defer {
                nextOffset += numericCast(ptr.pointee.cmdsize)
                nextIndex += 1
            }

            return LoadCommand.convert(ptr, offset: nextOffset)
        }
    }
}

extension MachO.LoadCommands: LoadCommandsProtocol {}
