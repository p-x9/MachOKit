//
//  MachOFile+Strings.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

extension MachOFile {
    public typealias Strings = UnicodeStrings<UTF8>
    public typealias UTF16Strings = UnicodeStrings<UTF16>

    public struct UnicodeStrings<Encoding: _UnicodeEncoding>: StringTable {
        public let data: Data

        /// file offset of string table start
        public let offset: Int

        /// size of string table
        public let size: Int

        public let isLittleEndian: Bool

        public func makeIterator() -> Iterator {
            .init(data: data, isLittleEndian: isLittleEndian)
        }
    }
}

extension MachOFile.UnicodeStrings {
    init(
        machO: MachOFile,
        offset: Int,
        size: Int,
        isLittleEndian: Bool = false
    ) {
        let data = machO.fileHandle.readData(
            offset: numericCast(offset),
            size: size
        )
        self.init(
            data: data,
            offset: offset,
            size: size,
            isLittleEndian: isLittleEndian
        )
    }
}

extension MachOFile.UnicodeStrings {
    public struct Iterator: IteratorProtocol {
        public typealias Element = StringTableEntry

        private let data: Data
        private let tableSize: Int
        private let isLittleEndian: Bool

        private var nextOffset: Int

        init(data: Data, isLittleEndian: Bool) {
            self.data = data
            self.tableSize = data.count
            self.isLittleEndian = isLittleEndian
            self.nextOffset = 0
        }

        public mutating func next() -> Element? {
            data.withUnsafeBytes {
                if nextOffset >= tableSize { return nil }
                guard let baseAddress = $0.baseAddress else { return nil }

                let ptr = baseAddress
                    .advanced(by: nextOffset)
                    .assumingMemoryBound(to: Encoding.CodeUnit.self)
                var (string, offset) = ptr.readString(as: Encoding.self)

                if isLittleEndian {
                    let data = Data(bytes: ptr, count: offset)
                    string = data.withUnsafeBytes {
                        let baseAddress = $0.baseAddress!
                            .assumingMemoryBound(to: Encoding.CodeUnit.self)
                        return .init(
                            decodingCString: baseAddress,
                            as: Encoding.self
                        )
                    }
                }

                let result = Element(string: string, offset: nextOffset)

                nextOffset += offset

                return  result
            }
        }
    }
}
