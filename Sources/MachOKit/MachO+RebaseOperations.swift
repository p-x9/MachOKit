//
//  MachO+RebaseOperations.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

extension MachO {
    public struct RebaseOperations: Sequence {
        public let basePointer: UnsafePointer<UInt8>
        public let rebaseSize: Int

        public func makeIterator() -> Iterator {
            .init(basePointer: basePointer, rebaseSize: rebaseSize)
        }
    }
}

extension MachO.RebaseOperations {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        info: dyld_info_command
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.rebase_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, rebaseSize: Int(info.rebase_size))
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        info: dyld_info_command
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.rebase_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, rebaseSize: Int(info.rebase_size))
    }
}

extension MachO.RebaseOperations {
    public struct Iterator: IteratorProtocol {
        public typealias Element = RebaseOperation

        private let basePointer: UnsafePointer<UInt8>
        private let rebaseSize: Int

        private var nextOffset: Int = 0
        private var done = false

        init(basePointer: UnsafePointer<UInt8>, rebaseSize: Int) {
            self.basePointer = basePointer
            self.rebaseSize = rebaseSize
        }

        public mutating func next() -> Element? {
            RebaseOperation.readNext(
                basePointer: basePointer,
                rebaseSize: rebaseSize,
                nextOffset: &nextOffset,
                done: &done
            )
        }
    }
}
