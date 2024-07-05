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
        public typealias Iterator = DataTrieTree<ExportTrieNodeContent>.Iterator

        public let exportOffset: Int
        public let exportSize: Int

        private let wrapped: DataTrieTree<ExportTrieNodeContent>

        public var data: Data {
            wrapped.data
        }

        public func makeIterator() -> Iterator {
            wrapped.makeIterator()
        }
    }
}

extension MachOFile.ExportTrieEntries {
    private init(
        machO: MachOFile,
        exportOffset: Int,
        exportSize: Int
    ) {
        let offset = machO.headerStartOffset + exportOffset
        let data = machO.fileHandle.readData(
            offset: numericCast(offset),
            size: exportSize
        )

        self.init(
            exportOffset: exportOffset,
            exportSize: exportSize,
            wrapped: .init(data: data)
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
