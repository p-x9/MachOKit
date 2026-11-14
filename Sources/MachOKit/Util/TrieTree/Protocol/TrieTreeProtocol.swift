//
//  TrieTreeProtocol.swift
//
//
//  Created by p-x9 on 2024/10/06
//
//

import Foundation

/// Protocol for structures representing Trie Tree
///  - ``DataTrieTree``: Handles the trie tree contained in `Data`
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
        var visited: Set<Int> = []
        recurseTrie(entry: root, result: &result, visited: &visited)
        return result
    }

    private func recurseTrie(
        entry: Element,
        result: inout [Element],
        visited: inout Set<Int>
    ) {
        guard visited.insert(entry.offset).inserted else { return }
        result.append(entry)
        for child in entry.children {
            guard let entry = element(atOffset: Int(child.offset)) else {
                continue
            }
            recurseTrie(
                entry: entry,
                result: &result,
                visited: &visited
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
        var visited: Set<Int> = []
        walkTrie(name: currentName, entry: entry, visited: &visited) { name, entry in
            if let content = entry.content {
                result.append((name, content))
            }
        }
    }

    /// Traverses the trie tree to obtain the names and node of all the terminals.
    /// - Parameters:
    ///   - currentName: current name
    ///   - entry: Node element  that is the root to start scanning
    ///   - result: All terminal names and terminal node of the `entry`.
    public func _recurseTrieTerminal(
        currentName: String,
        entry: Element,
        result: inout [(String, Element)]
    ) {
        var visited: Set<Int> = []
        walkTrie(name: currentName, entry: entry, visited: &visited) { name, entry in
            if entry.isTerminal {
                result.append((name, entry))
            }
        }
    }

    /// Depth-first walk that visits each node offset at most once, so that
    /// malformed tries containing cycles terminate.
    private func walkTrie(
        name: String,
        entry: Element,
        visited: inout Set<Int>,
        _ visit: (String, Element) -> Void
    ) {
        guard visited.insert(entry.offset).inserted else { return }
        visit(name, entry)
        for child in entry.children {
            guard let entry = element(atOffset: Int(child.offset)) else {
                continue
            }
            walkTrie(
                name: name + child.label,
                entry: entry,
                visited: &visited,
                visit
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
        var current = element(atOffset: 0)
        var visited: Set<Int> = [0]

        while true {
            guard let child = current?.children.first(
                where: { child in
                    key.starts(with: currentLabel + child.label)
                }
            ) else { break }
            let offset = Int(child.offset)
            guard visited.insert(offset).inserted else { break }
            currentLabel += child.label
            current = element(atOffset: offset)

            if key == currentLabel {
                guard let content = current?.content else {
                    return nil
                }
                return (offset, content)
            }
        }
        return nil
    }
}

extension TrieTreeProtocol {
    public func _search(
        byKeyPrefix prefix: String
    ) -> [(name: String, offset: Int, content: Content)] {
        guard !prefix.isEmpty else { return [] }

        var currentLabel = ""
        var current = element(atOffset: 0)
        var visited: Set<Int> = [0]

        while true {
            guard let child = current?.children.first(
                where: { child in
                    let label = currentLabel + child.label
                    return prefix.starts(with: label) || label.starts(with: prefix)
                }
            ) else { break }
            let offset = Int(child.offset)
            guard visited.insert(offset).inserted else { break }
            currentLabel += child.label
            current = element(atOffset: offset)

            if currentLabel.starts(with: prefix),
               let current {
                var result: [(String, Int, Content)] = []
                if let content = current.content {
                    result.append(
                        (currentLabel, numericCast(current.offset), content)
                    )
                }
                var terminals: [(String, Element)] = []
                _recurseTrieTerminal(currentName: currentLabel, entry: current, result: &terminals)
                result += terminals.compactMap {
                    guard let content = $1.content else { return nil }
                    return ($0, $1.offset, content)
                }
                return result
            }
        }
        return []
    }
}
