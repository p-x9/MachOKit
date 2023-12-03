//
//  ExportTrieEntries.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public struct ExportTrieEntries: Sequence {
    public let basePointer: UnsafePointer<UInt8>
    public let exportSize: Int

    public func makeIterator() -> Iterator {
        .init(basePointer: basePointer, exportSize: exportSize)
    }
}

extension ExportTrieEntries {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        info: dyld_info_command
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
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
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.export_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, exportSize: Int(info.export_size))
    }
}

extension ExportTrieEntries {
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
            guard nextOffset < exportSize else { return nil }

            let terminalSize = basePointer.advanced(by: nextOffset).pointee
            nextOffset += MemoryLayout<UInt8>.size

            var entry = ExportTrieEntry(
                terminalSize: terminalSize,
                children: []
            )

            var childrenOffset = nextOffset + Int(terminalSize)

            if terminalSize != 0 {
                let (flagsRaw, ulebOffset) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebOffset

                let flags = ExportSymbolFlags(rawValue: ExportSymbolFlags.RawValue(flagsRaw))
                entry.flags = flags

                if flags.contains(.reexport) {
                    let (value, ulebOffset) = basePointer
                        .advanced(by: nextOffset)
                        .readULEB128()
                    nextOffset += ulebOffset

                    entry.ordinal = value
                } else {
                    let (value, ulebOffset) = basePointer
                        .advanced(by: nextOffset)
                        .readULEB128()
                    nextOffset += ulebOffset

                    entry.symbolOffset = value
                }

                if flags.contains(.stub_and_resolver) || flags.contains(.static_resolver) {
                    let (string, stringOffset) = basePointer
                        .advanced(by: nextOffset)
                        .readString()
                    nextOffset += stringOffset

                    entry.importedName = string
                }
            }

            let numberOfChildren = basePointer
                .advanced(by: childrenOffset)
                .pointee
            childrenOffset += MemoryLayout<UInt8>.size

            for _ in 0..<numberOfChildren {
                let (string, stringOffset) = basePointer
                    .advanced(by: childrenOffset)
                    .readString()
                childrenOffset += stringOffset

                let (value, ulebOffset) = basePointer
                    .advanced(by: childrenOffset)
                    .readULEB128()
                childrenOffset += ulebOffset

                let child = ExportTrieEntry.Child(label: string, offset: value)
                entry.children.append(child)
            }

            nextOffset = childrenOffset

            return entry
        }
    }
}
