//
//  Strings.swift
//
//
//  Created by p-x9 on 2023/12/02.
//  
//

import Foundation

public struct Strings: Sequence {
    public struct Element: Codable, Equatable {
        let string: String
        let offset: Int // offset from start of string table
    }

    private let basePointer: UnsafePointer<CChar>
    private let tableSize: Int

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        symtab: LoadCommandInfo<symtab_command>
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        self.basePointer = ptr
            .advanced(by: numericCast(symtab.stroff))
            .advanced(by: numericCast(fileSlide))
            .assumingMemoryBound(to: CChar.self)
        self.tableSize = Int(symtab.strsize)
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        symtab: LoadCommandInfo<symtab_command>
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        self.basePointer = ptr
            .advanced(by: numericCast(symtab.stroff))
            .advanced(by: numericCast(fileSlide))
            .assumingMemoryBound(to: CChar.self)
        self.tableSize = Int(symtab.strsize)
    }

    public func makeIterator() -> Iterator {

        Iterator(
            basePointer: basePointer,
            tableSize: tableSize
        )
    }
}

extension Strings {
    public struct Iterator: IteratorProtocol {
        public typealias Element = Strings.Element

        private let basePointer: UnsafePointer<CChar>
        private let tableSize: Int

        private var nextPointer: UnsafePointer<CChar>

        init(basePointer: UnsafePointer<CChar>, tableSize: Int) {
            self.basePointer = basePointer
            self.tableSize = tableSize
            self.nextPointer = basePointer
        }

        public mutating func next() -> Element? {
            let offset = Int(bitPattern: nextPointer) - Int(bitPattern: basePointer)
            if offset >= tableSize {
                return nil
            }
            let string = String(cString: nextPointer)
            nextPointer = UnsafePointer(strchr(nextPointer, 0))
                .advanced(by: 1)

            return .init(string: string, offset: offset)
        }

    }
}
