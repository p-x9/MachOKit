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

extension TrieTreeProtocol {
    public func _search(for key: String) -> (offset: Int, content: Content)? {
        guard !key.isEmpty else { return nil }

        var currentLabel = ""
        var current = self.first(where: { _ in true })

        while true {
            guard let child = current?.children.first(
                where: { child in
                    key.starts(with: currentLabel + child.label)
                }
            ) else { break }
            currentLabel += child.label
            current = element(atOffset: numericCast(child.offset))

            if key == currentLabel {
                guard let content = current?.content else {
                    return nil
                }
                return (numericCast(child.offset), content)
            }
        }
        return nil
    }
}
