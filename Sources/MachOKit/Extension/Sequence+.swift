//
//  Sequence+.swift
//
//
//  Created by p-x9 on 2023/12/11.
//  
//

import Foundation

extension Sequence<ExportTrieEntry> {
    public var exportedSymbols: [ExportedSymbol] {
        let entries = Array(self)
        guard !entries.isEmpty else { return [] }

        let map: [Int: ExportTrieEntry] = Dictionary(
            uniqueKeysWithValues: entries.map {
                ($0.offset, $0)
            }
        )
        return extractExportedSymbols(
            currentName: "",
            currentOffset: 0,
            entry: entries[0],
            map: map
        )
    }

    /// https://opensource.apple.com/source/dyld/dyld-421.1/interlinked-dylibs/Trie.hpp.auto.html
    func extractExportedSymbols(
        currentName: String,
        currentOffset: Int,
        entry: ExportTrieEntry,
        map: [Int: ExportTrieEntry]
    ) -> [ExportedSymbol] {
        var currentOffset = currentOffset
        if let offset = entry.symbolOffset { currentOffset += Int(offset) }

        guard !entry.children.isEmpty else {
            return [
                ExportedSymbol(
                    name: currentName,
                    offset: currentOffset
                )
            ]
        }
        return entry.children.map {
            if let entry = map[Int($0.offset)] {
                return extractExportedSymbols(
                    currentName: currentName + $0.label,
                    currentOffset: currentOffset,
                    entry: entry,
                    map: map
                )
            } else {
                return [
                    ExportedSymbol(
                        name: currentName + $0.label,
                        offset: currentOffset
                    )
                ]
            }
        }.flatMap { $0 }
    }
}
