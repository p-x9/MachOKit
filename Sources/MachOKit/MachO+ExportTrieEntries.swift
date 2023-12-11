//
//  MachO+ExportTrieEntries.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

extension MachO {
    public struct ExportTrieEntries: Sequence {
        public let basePointer: UnsafePointer<UInt8>
        public let exportSize: Int

        public func makeIterator() -> Iterator {
            .init(basePointer: basePointer, exportSize: exportSize)
        }
    }
}

extension MachO.ExportTrieEntries {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        info: dyld_info_command
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - linkedit.fileoff 
        let ptr = ptr
            .advanced(by: Int(info.export_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, exportSize: Int(info.export_size))
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        info: dyld_info_command
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - linkedit.fileoff 
        let ptr = ptr
            .advanced(by: Int(info.export_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, exportSize: Int(info.export_size))
    }

    init(
        linkedit: SegmentCommand64,
        export: linkedit_data_command,
        vmaddrSlide: Int
    ) {

        let linkeditStart = vmaddrSlide + Int(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        let ptr = UnsafeRawPointer(bitPattern: linkeditStart)!
            .advanced(by: Int(export.dataoff))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, exportSize: Int(export.datasize))
    }

    init(
        linkedit: SegmentCommand,
        export: linkedit_data_command,
        vmaddrSlide: Int
    ) {
        let linkeditStart = vmaddrSlide + Int(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        let ptr = UnsafeRawPointer(bitPattern: linkeditStart)!
            .advanced(by: Int(export.dataoff))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, exportSize: Int(export.datasize))
    }
}

extension MachO.ExportTrieEntries {
    public struct Iterator: IteratorProtocol {
        public typealias Element = ExportTrieEntry

        private let basePointer: UnsafePointer<UInt8>
        private let exportSize: Int

        private var nextOffset: Int = 0

        init(basePointer: UnsafePointer<UInt8>, exportSize: Int) {
            self.basePointer = basePointer
            self.exportSize = exportSize
        }

        public mutating func next() -> ExportTrieEntry? {
            .readNext(
                basePointer: basePointer,
                exportSize: exportSize,
                nextOffset: &nextOffset
            )
        }
    }
}
