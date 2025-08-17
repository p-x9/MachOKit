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
        let ldVersion: Version?

        let wrapped: Wrapped

        var isPreDyld_1008: Bool {
            if let ldVersion {
                // Xcode 15.0 beta 1 (15A5160n)
                return ldVersion < .init(major: 1008, minor: 7, patch: 0)
            }
            return false // fallback
        }

        public var data: Data {
            wrapped.data
        }

        public func makeIterator() -> Iterator {
            .init(
                wrapped: wrapped.makeIterator(),
                isPreDyld_1008: isPreDyld_1008
            )
        }
    }
}

extension MachOFile.ExportTrie {
    /// All exported symbols from the trie tree
    public var exportedSymbols: [ExportedSymbol] {
        wrapped.exportedSymbols
    }

    /// Elements of each of the nodes that make up the trie tree
    ///
    /// It is obtained by traversing the nodes of the trie tree.It is obtained by traversing a trie tree.
    /// Slower than using `ExportTrie` iterator, but compatible with all Linker(ld) versions
    public var entries: [ExportTrieEntry] {
        wrapped.entries
    }

    /// Search the trie tree by symbol name to get the expoted symbol
    /// - Parameter key: symbol name
    /// - Returns: If found, retruns exported symbol
    public func search(by key: String) -> ExportedSymbol? {
        wrapped.search(by: key)
    }

    /// Search the trie tree by prefix of symbol name to get the expoted symbol
    /// - Parameter prefix: prefix of symbol name
    /// - Returns: If found, retruns exported symbol
    public func search(byKeyPrefix prefix: String) -> [ExportedSymbol] {
        wrapped.search(byKeyPrefix: prefix)
    }
}

extension MachOFile.ExportTrie {
    public struct Iterator: IteratorProtocol {
        public typealias Element = Wrapped.Element

        private var wrapped: Wrapped.Iterator
        let isPreDyld_1008: Bool

        @_spi(Support)
        public init(wrapped: Wrapped.Iterator, isPreDyld_1008: Bool) {
            self.wrapped = wrapped
            self.isPreDyld_1008 = isPreDyld_1008
        }

        public mutating func next() -> Element? {
            let isRoot = wrapped.nextOffset == 0

            guard let next = wrapped.next() else {
                return nil
            }

            // HACK: for after dyld-1008.7
            if isRoot && !isPreDyld_1008 {
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
        exportSize: Int,
        ldVersion: Version?
    ) {
        let data = machO._readLinkEditData(
            offset: exportOffset,
            length: exportSize
        )!

        self.init(
            exportOffset: exportOffset,
            exportSize: exportSize,
            ldVersion: ldVersion,
            wrapped: .init(data: data)
        )
    }

    init(
        machO: MachOFile,
        info: dyld_info_command,
        ldVersion: Version?
    ) {
        self.init(
            machO: machO,
            exportOffset: numericCast(info.export_off),
            exportSize: numericCast(info.export_size),
            ldVersion: ldVersion
        )
    }

    init(
        machO: MachOFile,
        export: linkedit_data_command,
        ldVersion: Version?
    ) {
        self.init(
            machO: machO,
            exportOffset: numericCast(export.dataoff),
            exportSize: numericCast(export.datasize),
            ldVersion: ldVersion
        )
    }
}
