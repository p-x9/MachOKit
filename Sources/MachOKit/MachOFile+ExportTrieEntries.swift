//
//  MachOFile+ExportTrieEntries.swift
//
//
//  Created by p-x9 on 2023/12/09.
//  
//

import Foundation

extension MachOFile {
    public struct ExportTrieEntries {
        let machO: MachOFile
        public let exportOffset: Int
        public let exportSize: Int
    }
}

extension MachOFile.ExportTrieEntries: Sequence {
    init(
        machO: MachOFile,
        info: dyld_info_command
    ) {
        self.init(
            machO: machO,
            exportOffset: Int(info.export_off),
            exportSize: Int(info.export_size)
        )
    }

    public func makeIterator() -> Iterator {
        let offset = machO.headerStartOffset + exportOffset
        machO.fileHandle.seek(
            toFileOffset: UInt64(offset)
        )

        // FIXME: exportSize does not include the size of the last entry's children information
        // Therefore, read to the end of the file.
        let data = machO.fileHandle.readDataToEndOfFile()

        return .init(data: data, exportSize: exportSize)
    }
}

extension MachOFile.ExportTrieEntries {
    public struct Iterator: IteratorProtocol {
        public typealias Element = ExportTrieEntry

        private let data: Data
        private var nextOffset: Int = 0
        private let exportSize: Int

        init(data: Data, exportSize: Int) {
            self.data = data
            self.exportSize = exportSize
        }

        public mutating func next() -> ExportTrieEntry? {
            guard nextOffset < data.count else { return nil }

            return data.withUnsafeBytes {
                guard let basePointer = $0.baseAddress else { return nil }

                return .readNext(
                    basePointer: basePointer.assumingMemoryBound(to: UInt8.self),
                    exportSize: exportSize,
                    nextOffset: &nextOffset
                )
            }
        }
    }
}
