//
//  MachOImage+ExportTrieEntries.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

extension MachOImage {
    public struct ExportTrieEntries: Sequence {
        public typealias Iterator = MemoryTrieTree<ExportTrieNodeContent>.Iterator

        private let wrapped: MemoryTrieTree<ExportTrieNodeContent>

        public var basePointer: UnsafeRawPointer {
            wrapped.basePointer
        }
        public var exportSize: Int {
            wrapped.size
        }

        init(wrapped: MemoryTrieTree<ExportTrieNodeContent>) {
            self.wrapped = wrapped
        }

        public func makeIterator() -> Iterator {
            wrapped.makeIterator()
        }
    }
}

extension MachOImage.ExportTrieEntries {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        info: dyld_info_command
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.export_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(info.export_size))
        )
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        info: dyld_info_command
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.export_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(info.export_size))
        )
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

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(export.datasize))
        )
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

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(export.datasize))
        )
    }
}
