//
//  MachO.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public struct MachO {
    public let ptr: UnsafeRawPointer

    public let is64Bit: Bool
    public let loadCommands: LoadCommands

    public init(ptr: UnsafePointer<mach_header>) {
        self.ptr = .init(ptr)

        let header = ptr.pointee

        self.is64Bit = header.magic == MH_MAGIC_64 || header.magic == MH_CIGAM_64
        let start = UnsafeRawPointer(ptr)
            .advanced(
                by: is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
            )
        loadCommands = .init(start: start, numberOfCommands: Int(header.ncmds))
    }
}

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

        mutating public func next() -> Element? {
            guard nextIndex < numberOfCommands else {
                return nil
            }
            let ptr = start.advanced(by: nextOffset)
                .assumingMemoryBound(to: load_command.self)

            let next = LoadCommand.convert(ptr, offset: nextOffset)

            nextOffset += Int(ptr.pointee.cmdsize)
            nextIndex += 1

            return next
        }
    }
}
