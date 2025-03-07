//
//  TrieTreeProtocol.swift
//
//
//  Created by p-x9 on 2024/10/06
//
//

import Foundation

/// Protocol for structures representing Trie Tree
///  - ``DataTrieTree``: Handles the trie tree contained in ``Data``
///  - ``MemoryTrieTree``: Handles the trie tree exsisted on memory
///
/// It conforms to Sequence and sequentially retrieves the elements of the tree
/// that exist contiguously in memory space.
///
/// To retrieve all elements, it is more accurate to use the `entries` parameter, which traverses each node.
/// This is because some trie trees contain meaningless spaces between elements, which may not be contiguous in memory space.
public protocol TrieTreeProtocol<Content>: Sequence where Element == TrieNode<Content> {
    associatedtype Content: TrieNodeContent

    func element(atOffset offset: Int) -> Element?
}

extension TrieTreeProtocol {
    /// Elements of each of the nodes that make up the trie tree
    ///
    /// It is obtained by traversing the nodes of the trie tree.It is obtained by traversing a trie tree.
    /// In the case of traversal by the `Self` iterator, elements of contiguous memory space are retrieved sequentially.
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
    /// Traverses the trie tree to obtain the names and contents of all the terminals.
    /// - Parameters:
    ///   - currentName: current name
    ///   - entry: Node element  that is the root to start scanning
    ///   - result: All terminal names and contents of the `entry`.
    public func _recurseTrie(
        currentName: String,
        entry: Element,
        result: inout [(String, Content)]
    ) {
        if let content = entry.content {
            result.append((currentName, content))
        }
        for child in entry.children {
            guard let entry = element(atOffset: Int(child.offset)) else {
                continue
            }
            _recurseTrie(
                currentName: currentName + child.label,
                entry: entry,
                result: &result
            )
        }
    }
}

extension TrieTreeProtocol {
    /// Search the trie tree by name to get terminal content and node offset
    /// - Parameter key: name
    /// - Returns: If found, retruns terminal content and node offset
    public func _search(by key: String) -> (offset: Int, content: Content)? {
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
