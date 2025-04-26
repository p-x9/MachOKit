//
//  Strings.swift
//
//
//  Created by p-x9 on 2023/12/02.
//  
//

import Foundation

extension MachOImage {
    public typealias Strings = UnicodeStrings<UTF8>
    public typealias UTF16Strings = UnicodeStrings<UTF16>

    public struct UnicodeStrings<Encoding: _UnicodeEncoding>: StringTable {
        public let basePointer: UnsafePointer<Encoding.CodeUnit>
        public let tableSize: Int

        public let isLittleEndian: Bool

        init(
            basePointer: UnsafePointer<Encoding.CodeUnit>,
            tableSize: Int,
            isLittleEndian: Bool = false
        ) {
            self.basePointer = basePointer
            self.tableSize = tableSize
            self.isLittleEndian = isLittleEndian
        }

        public func makeIterator() -> Iterator {
            Iterator(
                basePointer: basePointer,
                tableSize: tableSize,
                isLittleEndian: isLittleEndian
            )
        }
    }
}

extension MachOImage.UnicodeStrings {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        symtab: LoadCommandInfo<symtab_command>,
        isLittleEndian: Bool = false
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        self.basePointer = ptr
            .advanced(by: numericCast(symtab.stroff))
            .advanced(by: numericCast(fileSlide))
            .assumingMemoryBound(to: Encoding.CodeUnit.self)
        self.tableSize = Int(symtab.strsize)
        self.isLittleEndian = isLittleEndian
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        symtab: LoadCommandInfo<symtab_command>,
        isLittleEndian: Bool = false
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        self.basePointer = ptr
            .advanced(by: numericCast(symtab.stroff))
            .advanced(by: numericCast(fileSlide))
            .assumingMemoryBound(to: Encoding.CodeUnit.self)
        self.tableSize = Int(symtab.strsize)
        self.isLittleEndian = isLittleEndian
    }
}

extension MachOImage.UnicodeStrings {
    public struct Iterator: IteratorProtocol {
        public typealias Element = StringTableEntry

        private let basePointer: UnsafePointer<Encoding.CodeUnit>
        private let tableSize: Int
        private let isLittleEndian: Bool

        private var nextPointer: UnsafePointer<Encoding.CodeUnit>

        init(
            basePointer: UnsafePointer<Encoding.CodeUnit>,
            tableSize: Int,
            isLittleEndian: Bool
        ) {
            self.basePointer = basePointer
            self.tableSize = tableSize
            self.isLittleEndian = isLittleEndian
            self.nextPointer = basePointer
        }

        public mutating func next() -> Element? {
            let offset = Int(bitPattern: nextPointer) - Int(bitPattern: basePointer)
            if offset >= tableSize {
                return nil
            }
            var (string, nextOffset) = nextPointer.readString(
                as: Encoding.self
            )

            if isLittleEndian {
                let data = Data(bytes: nextPointer, count: offset)
                string = data.withUnsafeBytes {
                    let baseAddress = $0.baseAddress!
                        .assumingMemoryBound(to: Encoding.CodeUnit.self)
                    return .init(
                        decodingCString: baseAddress,
                        as: Encoding.self
                    )
                }
            }

            nextPointer = nextPointer.advanced(
                by: nextOffset / MemoryLayout<Encoding.CodeUnit>.size
            )

            return .init(string: string, offset: offset)
        }
    }
}
