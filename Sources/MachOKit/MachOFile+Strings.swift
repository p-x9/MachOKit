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
    init(
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
    public struct Iterator: IteratorProtocol {
        public typealias Element = StringTableEntry

        private let fileSice: FileSlice
        private let tableSize: Int
        private let isSwapped: Bool

        private var nextOffset: Int

        init(fileSlice: FileSlice, isSwapped: Bool) {
            self.fileSice = fileSlice
            self.tableSize = fileSlice.size
            self.nextOffset = 0
            self.isSwapped = isSwapped
        }

        public mutating func next() -> Element? {
            guard nextOffset < tableSize else { return nil }

            let ptr = UnsafeRawPointer(fileSice.ptr)
                .advanced(by: nextOffset)
                .assumingMemoryBound(to: Encoding.CodeUnit.self)
            var (string, offset) = ptr.readString(as: Encoding.self)

            defer {
                nextOffset += offset
            }

            if isSwapped || shouldSwap(ptr) {
                let data = Data(bytes: ptr, count: offset)
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

            return .init(
                string: string,
                offset: nextOffset
            )
        }
    }
}

extension MachOFile.UnicodeStrings.Iterator {
    // https://github.com/swiftlang/swift-corelibs-foundation/blob/4a9694d396b34fb198f4c6dd865702f7dc0b0dcf/Sources/Foundation/NSString.swift#L1390
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
