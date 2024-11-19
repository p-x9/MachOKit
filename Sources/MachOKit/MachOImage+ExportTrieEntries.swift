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
        public typealias Wrapped = MemoryTrieTree<ExportTrieNodeContent>

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
            .init(wrapped: wrapped.makeIterator())
        }
    }
}

extension MachOImage.ExportTrieEntries {
    public var exportedSymbols: [ExportedSymbol] {
        wrapped.exportedSymbols
    }

    public var entries: [ExportTrieEntry] {
        wrapped.entries
    }

    public func search(for key: String) -> ExportedSymbol? {
        wrapped.search(for: key)
    }
}

extension MachOImage.ExportTrieEntries {
    public struct Iterator: IteratorProtocol {
        public typealias Element = Wrapped.Element

        private var wrapped: Wrapped.Iterator

        @_spi(Support)
        public init(wrapped: Wrapped.Iterator) {
            self.wrapped = wrapped
        }

        public mutating func next() -> Element? {
            let isRoot = wrapped.nextOffset == 0

            guard let next = wrapped.next() else {
                return nil
            }

            // HACK: for after dyld-1122.1
            if isRoot {
                // ref: https://github.com/apple-oss-distributions/dyld/blob/main/mach_o/ExportsTrie.cpp#L669-L674
                // root is allocated the size that `UINT_MAX` can represent
                // 32 / 7
                wrapped.nextOffset -= next.children
                    .map(\.offset.uleb128Size)
                    .reduce(0, +)
                wrapped.nextOffset += 5 * next.children.count
            }

            return next
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
        let ptr = UnsafeRawPointer(bitPattern: linkeditStart)! // swiftlint:disable:this force_unwrapping
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
        let ptr = UnsafeRawPointer(bitPattern: linkeditStart)! // swiftlint:disable:this force_unwrapping
            .advanced(by: Int(export.dataoff))
            .assumingMemoryBound(to: UInt8.self)

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(export.datasize))
        )
    }
}
