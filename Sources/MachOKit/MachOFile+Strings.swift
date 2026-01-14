//
//  MachOFile+Strings.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
#else
@_implementationOnly import FileIO
#endif

extension MachOFile {
    public typealias Strings = UnicodeStrings<UTF8>
    public typealias UTF16Strings = UnicodeStrings<UTF16>

    public struct UnicodeStrings<Encoding: _UnicodeEncoding>: StringTable {
        typealias FileSlice = File.FileSlice

        private let fileSlice: FileSlice

        /// file offset of string table start
        public let offset: Int

        /// size of string table
        public let size: Int

        public let isSwapped: Bool

        init(
            fileSlice: FileSlice,
            offset: Int,
            size: Int,
            isSwapped: Bool
        ) {
            self.fileSlice = fileSlice
            self.offset = offset
            self.size = size
            self.isSwapped = isSwapped
        }

        public func makeIterator() -> Iterator {
            .init(fileSlice: fileSlice, isSwapped: isSwapped)
        }
    }
}

extension MachOFile.UnicodeStrings {
    @_spi(Support)
    public init(
        machO: MachOFile,
        offset: Int,
        size: Int,
        isSwapped: Bool
    ) {
        let fileSlice = try! machO.fileHandle.fileSlice(
            offset: offset,
            length: size
        )
        self.init(
            fileSlice: fileSlice,
            offset: offset,
            size: size,
            isSwapped: isSwapped
        )
    }
}

extension MachOFile.UnicodeStrings {
    public var data: Data? {
        try? fileSlice.readAllData()
    }
}

extension MachOFile.UnicodeStrings {
    public func string(at offset: Int) -> Element? {
        guard 0 <= offset, offset < fileSlice.size else { return nil }

        guard let (_string, length) = fileSlice._readString(
            offset: numericCast(offset),
            as: Encoding.self
        ) else {
            return nil
        }
        var string = _string

        let char = try! fileSlice.read(
            offset: offset,
            as: Encoding.CodeUnit.self
        )

        if isSwapped || Iterator.shouldSwap(char) {
            handleSwap(
                string: &string,
                at: offset,
                length: length,
                fileHandle: fileSlice,
                hasBOM: Iterator.shouldSwap(char),
                encoding: Encoding.self
            )
        }
        return .init(string: string, offset: offset)
    }
}

extension MachOFile.UnicodeStrings {
    public struct Iterator: IteratorProtocol {
        public typealias Element = StringTableEntry

        private let fileSlice: FileSlice
        private let tableSize: Int
        private let isSwapped: Bool

        private var nextOffset: Int

        init(fileSlice: FileSlice, isSwapped: Bool) {
            self.fileSlice = fileSlice
            self.tableSize = fileSlice.size
            self.nextOffset = 0
            self.isSwapped = isSwapped
        }

        public mutating func next() -> Element? {
            guard nextOffset < tableSize else { return nil }

            guard let (_string, length) = fileSlice._readString(
                offset: nextOffset,
                as: Encoding.self
            ) else { return nil }
            var string = _string

            defer {
                nextOffset += length
            }

            let char = try! fileSlice.read(
                offset: nextOffset,
                as: Encoding.CodeUnit.self
            )

            if isSwapped || Self.shouldSwap(char) {
                handleSwap(
                    string: &string,
                    at: nextOffset,
                    length: length,
                    fileHandle: fileSlice,
                    hasBOM: Self.shouldSwap(char),
                    encoding: Encoding.self
                )
            }

            return .init(
                string: string,
                offset: nextOffset
            )
        }
    }
}

extension MachOFile.UnicodeStrings.Iterator {
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
    at offset: Int,
    length: Int,
    fileHandle: some _FileIOProtocol,
    hasBOM: Bool,
    encoding: Encoding.Type
) {
    var data = try! fileHandle.readData(
        offset: offset,
        length: length
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
