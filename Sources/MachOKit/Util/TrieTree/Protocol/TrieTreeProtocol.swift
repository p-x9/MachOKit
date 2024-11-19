//
//  TrieTreeProtocol.swift
//
//
//  Created by p-x9 on 2024/10/06
//
//

import Foundation

public protocol TrieTreeProtocol<Content>: Sequence where Element == TrieNode<Content> {
    associatedtype Content: TrieNodeContent

    func element(atOffset offset: Int) -> Element?
}

extension TrieTreeProtocol {
    public var entries: [Element] {
        guard let root = first(where: { _ in true}) else {
            return []
        }
        var result: [Element] = []
        recurseTrie(entry: root, result: &result)
        return result
    }

    private func recurseTrie(
        entry: Element,
        result: inout [Element]
    ) {
        result.append(entry)
        for child in entry.children {
            guard let entry = element(atOffset: Int(child.offset)) else {
                continue
            }
            recurseTrie(
                entry: entry,
                result: &result
            )
        }
    }
}
