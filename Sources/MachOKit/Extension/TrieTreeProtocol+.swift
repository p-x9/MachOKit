//
//  TrieTreeProtocol+.swift
//  MachOKit
//
//  Created by p-x9 on 2024/11/20
//  
//

import Foundation

extension TrieTreeProtocol where Content == ExportTrieNodeContent {
    func recurseTrie(
        currentName: String,
        entry: Element,
        result: inout [ExportedSymbol]
    ) {
        if let content = entry.content {
            let symbolOffset: Int? = if let symbolOffset = content.symbolOffset {
                .init(bitPattern: symbolOffset)
            } else { nil }
            result.append(
                ExportedSymbol(
                    name: currentName,
                    offset: symbolOffset,
                    flags: content.flags ?? [],
                    ordinal: content.ordinal,
                    importedName: content.importedName,
                    stub: content.stub,
                    resolver: content.resolver
                )
            )
        }
        for child in entry.children {
            guard let entry = element(atOffset: Int(child.offset)) else {
                continue
            }
            recurseTrie(
                currentName: currentName + child.label,
                entry: entry,
                result: &result
            )
        }
    }
}
