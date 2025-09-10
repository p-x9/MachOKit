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

        init(
            basePointer: UnsafePointer<Encoding.CodeUnit>,
            tableSize: Int
        ) {
            self.basePointer = basePointer
            self.tableSize = tableSize
        }

        public func makeIterator() -> Iterator {
            Iterator(
                basePointer: basePointer,
                tableSize: tableSize
            )
        }
    }
}

extension MachOImage.UnicodeStrings {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        symtab: LoadCommandInfo<symtab_command>
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        self.basePointer = ptr
            .advanced(by: numericCast(symtab.stroff))
            .advanced(by: numericCast(fileSlide))
            .assumingMemoryBound(to: Encoding.CodeUnit.self)
        self.tableSize = Int(symtab.strsize)
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        symtab: LoadCommandInfo<symtab_command>
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        self.basePointer = ptr
            .advanced(by: numericCast(symtab.stroff))
            .advanced(by: numericCast(fileSlide))
            .assumingMemoryBound(to: Encoding.CodeUnit.self)
        self.tableSize = Int(symtab.strsize)
    }
}

extension MachOImage.Strings {
    public func string(at offset: Int) -> Element? {
        guard 0 <= offset, offset < tableSize else { return nil }
        let string = String(
            cString: UnsafeRawPointer(basePointer)
                .advanced(by: offset)
                .assumingMemoryBound(to: CChar.self)
        )
        return .init(string: string, offset: offset)
    }
}

extension MachOImage.UnicodeStrings {
    public struct Iterator: IteratorProtocol {
        public typealias Element = StringTableEntry

        private let basePointer: UnsafePointer<Encoding.CodeUnit>
        private let tableSize: Int

        private var nextPointer: UnsafePointer<Encoding.CodeUnit>

        init(
            basePointer: UnsafePointer<Encoding.CodeUnit>,
            tableSize: Int
        ) {
            self.basePointer = basePointer
            self.tableSize = tableSize
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

            if shouldSwap(nextPointer) {
                let data = Data(bytes: nextPointer, count: offset)
                    .byteSwapped(Encoding.CodeUnit.self)
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

extension MachOImage.UnicodeStrings.Iterator {
    func shouldSwap(_ ptr: UnsafePointer<Encoding.CodeUnit>) -> Bool {
        let size = MemoryLayout<Encoding.CodeUnit>.size
        switch size {
        case 1:
            return false
        case 2:
            return ptr.pointee == 0xFFFE /* ZERO WIDTH NO-BREAK SPACE (swapped) */
        case 4:
            return ptr.pointee == UInt32(0xFFFE0000) // avoid overflows in 32bit env
        default:
            return false
        }
    }
}
