//
//  MachOFile+ExportTrieEntries.swift
//
//
//  Created by p-x9 on 2023/12/09.
//  
//

import Foundation

extension MachOFile {
    public struct ExportTrieEntries: Sequence {
        public let data: Data
        public let exportOffset: Int
        public let exportSize: Int

        public func makeIterator() -> Iterator {
            .init(data: data)
        }
    }
}

extension MachOFile.ExportTrieEntries {
    init(
        machO: MachOFile,
        exportOffset: Int,
        exportSize: Int
    ) {
        let offset = machO.headerStartOffset + exportOffset
        machO.fileHandle.seek(
            toFileOffset: UInt64(offset)
        )
        let data = machO.fileHandle.readData(ofLength: exportSize)

        self.init(
            data: data,
            exportOffset: exportOffset,
            exportSize: exportSize
        )
    }

    init(
        machO: MachOFile,
        info: dyld_info_command
    ) {
        self.init(
            machO: machO,
            exportOffset: numericCast(info.export_off),
            exportSize: numericCast(info.export_size)
        )
    }

    init(
        machO: MachOFile,
        export: linkedit_data_command
    ) {
        self.init(
            machO: machO,
            exportOffset: numericCast(export.dataoff),
            exportSize: numericCast(export.datasize)
        )
    }
}

extension MachOFile.ExportTrieEntries {
    public struct Iterator: IteratorProtocol {
        public typealias Element = ExportTrieEntry

        private let data: Data
        private var nextOffset: Int = 0

        init(data: Data) {
            self.data = data
        }

        public mutating func next() -> ExportTrieEntry? {
            guard nextOffset < data.count else { return nil }

            return data.withUnsafeBytes {
                guard let basePointer = $0.baseAddress else { return nil }

                return .readNext(
                    basePointer: basePointer.assumingMemoryBound(to: UInt8.self),
                    exportSize: data.count,
                    nextOffset: &nextOffset
                )
            }
        }
    }
}
