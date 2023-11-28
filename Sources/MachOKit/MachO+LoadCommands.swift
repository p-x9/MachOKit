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

extension MachO.LoadCommands {
    var text: SegmentCommand? {
        compactMap {
            if case let .segment(info) = $0,
               info.segmentName == SEG_TEXT { info }
            else { nil }
        }.first
    }

    var text64: SegmentCommand64? {
        compactMap {
            if case let .segment64(info) = $0,
               info.segmentName == SEG_TEXT { info }
            else { nil }
        }.first
    }

    var linkedit: SegmentCommand? {
        compactMap {
            if case let .segment(info) = $0,
               info.segmentName == SEG_LINKEDIT { info }
            else { nil }
        }.first
    }

    var linkedit64: SegmentCommand64? {
        compactMap {
            if case let .segment64(info) = $0,
               info.segmentName == SEG_LINKEDIT { info }
            else { nil }
        }.first
    }

    var symtab: LoadCommandInfo<symtab_command>? {
        compactMap {
            if case let .symtab(info) = $0 { info }
            else { nil }
        }.first
    }
}
