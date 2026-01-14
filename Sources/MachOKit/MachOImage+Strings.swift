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

        public let isSwapped: Bool

        @_spi(Support)
        public init(
            basePointer: UnsafePointer<Encoding.CodeUnit>,
            tableSize: Int,
            isSwapped: Bool = false
        ) {
            self.basePointer = basePointer
            self.tableSize = tableSize
            self.isSwapped = isSwapped
        }

        public func makeIterator() -> Iterator {
            Iterator(
                basePointer: basePointer,
                tableSize: tableSize,
                isSwapped: isSwapped
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
        isSwapped: Bool = false
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        self.basePointer = ptr
            .advanced(by: numericCast(symtab.stroff))
            .advanced(by: numericCast(fileSlide))
            .assumingMemoryBound(to: Encoding.CodeUnit.self)
        self.tableSize = Int(symtab.strsize)
        self.isSwapped = isSwapped
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        symtab: LoadCommandInfo<symtab_command>,
        isSwapped: Bool = false
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        self.basePointer = ptr
            .advanced(by: numericCast(symtab.stroff))
            .advanced(by: numericCast(fileSlide))
            .assumingMemoryBound(to: Encoding.CodeUnit.self)
        self.tableSize = Int(symtab.strsize)
        self.isSwapped = isSwapped
    }
}

extension MachOImage.UnicodeStrings {
    public func string(at offset: Int) -> Element? {
        guard 0 <= offset, offset < tableSize else { return nil }

        let ptr = basePointer.advanced(by: offset)

        var (string, length) = ptr
            .readString(as: Encoding.self)

        let char = ptr.pointee

        if isSwapped || Iterator.shouldSwap(char) {
            handleSwap(
                string: &string,
                length: length,
                ptr: ptr,
                hasBOM: Iterator.shouldSwap(char),
                encoding: Encoding.self
            )
        }

        return .init(string: string, offset: offset)
    }
}

extension MachOImage.UnicodeStrings {
    public struct Iterator: IteratorProtocol {
        public typealias Element = StringTableEntry

        private let basePointer: UnsafePointer<Encoding.CodeUnit>
        private let tableSize: Int
        private let isSwapped: Bool

        private var nextPointer: UnsafePointer<Encoding.CodeUnit>

        init(
            basePointer: UnsafePointer<Encoding.CodeUnit>,
            tableSize: Int,
            isSwapped: Bool
        ) {
            self.basePointer = basePointer
            self.tableSize = tableSize
            self.nextPointer = basePointer
            self.isSwapped = isSwapped
        }

        public mutating func next() -> Element? {
            let offset = Int(bitPattern: nextPointer) - Int(bitPattern: basePointer)
            if offset >= tableSize {
                return nil
            }
            var (string, length) = nextPointer.readString(
                as: Encoding.self
            )

            let char = nextPointer.pointee

            if isSwapped || Self.shouldSwap(char) {
                handleSwap(
                    string: &string,
                    length: length,
                    ptr: nextPointer,
                    hasBOM: Self.shouldSwap(char),
                    encoding: Encoding.self
                )
            }

            nextPointer = nextPointer.advanced(
                by: length / MemoryLayout<Encoding.CodeUnit>.size
            )

            return .init(string: string, offset: offset)
        }
    }
}

extension MachOImage.UnicodeStrings.Iterator {
    // https://github.com/swiftlang/swift-corelibs-foundation/blob/4a9694d396b34fb198f4c6dd865702f7dc0b0dcf/Sources/Foundation/NSString.swift#L1390
    static func shouldSwap(
        _ char: Encoding.CodeUnit
    ) -> Bool {
        let size = MemoryLayout<Encoding.CodeUnit>.size
        var char = char
        if Endian.current == .little {
            char = char.byteSwapped
        }
        switch size {
        case 1:
            return false
        case 2:
            return char == 0xFFFE /* ZERO WIDTH NO-BREAK SPACE */
        case 4:
            return char == UInt32(0xFFFE0000) // avoid overflows in 32bit env
        default:
            return false
        }
    }
}

fileprivate func handleSwap<Encoding: _UnicodeEncoding>(
    string: inout String,
    length: Int,
    ptr: UnsafePointer<Encoding.CodeUnit>,
    hasBOM: Bool,
    encoding: Encoding.Type
) {
    var data = Data(
        bytes: ptr,
        count: length
    )

    // strip BOM
    if hasBOM {
        data.removeFirst(MemoryLayout<Encoding.CodeUnit>.size)
    }

    data = data.byteSwapped(Encoding.CodeUnit.self)

    string = data.withUnsafeBytes {
        let baseAddress = $0.baseAddress!
            .assumingMemoryBound(to: Encoding.CodeUnit.self)
        return .init(
            decodingCString: baseAddress,
            as: Encoding.self
        )
    }
}
