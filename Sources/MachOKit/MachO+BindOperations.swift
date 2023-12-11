//
//  MachO+BindOperations.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

extension MachO {
    public struct BindOperations: Sequence {
        public let basePointer: UnsafePointer<UInt8>
        public let bindSize: Int

        public func makeIterator() -> Iterator {
            .init(basePointer: basePointer, bindSize: bindSize)
        }
    }
}

extension MachO.BindOperations {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        info: dyld_info_command,
        kind: BindOperationsKind = .normal
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - linkedit.fileoff 
        let ptr = ptr
            .advanced(by: Int(kind.bindOffset(of: info)))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, bindSize: Int(kind.bindSize(of: info)))
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        info: dyld_info_command,
        kind: BindOperationsKind = .normal
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - linkedit.fileoff 
        let ptr = ptr
            .advanced(by: Int(kind.bindOffset(of: info)))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, bindSize: Int(kind.bindSize(of: info)))
    }
}

extension MachO.BindOperations {
    public struct Iterator: IteratorProtocol {
        public typealias Element = BindOperation

        private let basePointer: UnsafePointer<UInt8>
        private let bindSize: Int

        private var nextOffset: Int = 0

        init(basePointer: UnsafePointer<UInt8>, bindSize: Int) {
            self.basePointer = basePointer
            self.bindSize = bindSize
        }

        public mutating func next() -> Element? {
            BindOperation.readNext(
                basePointer: basePointer,
                bindSize: bindSize,
                nextOffset: &nextOffset
            )
        }
    }
}
