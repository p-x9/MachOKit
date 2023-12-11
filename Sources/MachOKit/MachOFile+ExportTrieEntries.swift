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
        let machO: MachOFile
        public let exportOffset: Int
        public let exportSize: Int

        public func makeIterator() -> Iterator {
            let offset = machO.headerStartOffset + exportOffset
            machO.fileHandle.seek(
                toFileOffset: UInt64(offset)
            )

            let data = machO.fileHandle.readData(ofLength: exportSize)

            return .init(data: data)
        }
    }
}

extension MachOFile.ExportTrieEntries {
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

    init(
        machO: MachOFile,
        linkedit: SegmentCommand64,
        export: linkedit_data_command
    ) {
        self.init(
            machO: machO,
            exportOffset: Int(export.dataoff), // No need to consider headerStartOffset
            exportSize: Int(export.datasize)
        )
    }

    init(
        machO: MachOFile,
        linkedit: SegmentCommand,
        export: linkedit_data_command
    ) {
        self.init(
            machO: machO,
            exportOffset: Int(export.dataoff), //　No need to consider headerStartOffset
            exportSize: Int(export.datasize)
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
