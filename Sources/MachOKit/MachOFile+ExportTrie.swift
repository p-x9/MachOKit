//
//  MachOFile+ExportTrie.swift
//
//
//  Created by p-x9 on 2023/12/09.
//
//

import Foundation

extension MachOFile {
    // https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/mach_o/ExportsTrie.cpp
    // https://github.com/apple-oss-distributions/ld64/blob/47f477cb721755419018f7530038b272e9d0cdea/src/mach_o/ExportsTrie.cpp
    public struct ExportTrie: Sequence {
        public typealias Wrapped = DataTrieTree<ExportTrieNodeContent>

        public let exportOffset: Int
        public let exportSize: Int

        let wrapped: Wrapped

        public var data: Data {
            wrapped.data
        }

        public func makeIterator() -> Iterator {
            .init(wrapped: wrapped.makeIterator())
        }
    }
}

extension MachOFile.ExportTrie {
    public var exportedSymbols: [ExportedSymbol] {
        wrapped.exportedSymbols
    }

    public var entries: [ExportTrieEntry] {
        wrapped.entries
    }

    public func search(for key: String) -> ExportedSymbol? {
        wrapped.search(for: key)
    }
}

extension MachOFile.ExportTrie {
    public struct Iterator: IteratorProtocol {
        public typealias Element = Wrapped.Element

        private var wrapped: Wrapped.Iterator

        @_spi(Support)
        public init(wrapped: Wrapped.Iterator) {
            self.wrapped = wrapped
        }

        public mutating func next() -> Element? {
            let isRoot = wrapped.nextOffset == 0

            guard let next = wrapped.next() else {
                return nil
            }

            // HACK: for after dyld-1122.1
            if isRoot {
                // ref: https://github.com/apple-oss-distributions/dyld/blob/main/mach_o/ExportsTrie.cpp#L669-L674
                // root is allocated the size that `UINT_MAX` can represent
                // 32 / 7
                wrapped.nextOffset -= next.children
                    .map(\.offset.uleb128Size)
                    .reduce(0, +)
                wrapped.nextOffset += 5 * next.children.count
            }

            return next
        }
    }
}

extension MachOFile.ExportTrie {
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
