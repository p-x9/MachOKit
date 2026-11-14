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
        walkTrie(name: "", entry: root) { entry, _ in
            result.append(entry)
        }
        return result
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
        walkTrie(name: currentName, entry: entry) { entry, name in
            if let content = entry.content {
                result.append((name(), content))
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
        walkTrie(name: currentName, entry: entry) { entry, name in
            if entry.isTerminal {
                result.append((name(), entry))
            }
        }
    }

    /// Pre-order walk with an explicit stack, so that deep tries cannot overflow
    /// the call stack. Only nodes already on the current path are skipped, so
    /// cycles terminate while shared nodes are still visited via every parent.
    private func walkTrie(
        name: String,
        entry root: Element,
        _ visit: (_ entry: Element, _ name: () -> String) -> Void
    ) {
        var nameBytes = Array(name.utf8)
        var path: Set<Int> = [root.offset]
        var stack: [(entry: Element, nameCount: Int, nextChild: Int)] = [
            (root, nameBytes.count, 0)
        ]
        visit(root) { name }

        while let top = stack.last {
            guard top.nextChild < top.entry.children.count else {
                path.remove(top.entry.offset)
                stack.removeLast()
                continue
            }
            stack[stack.count - 1].nextChild += 1

            let child = top.entry.children[top.nextChild]
            guard let entry = element(atOffset: Int(child.offset)),
                  path.insert(entry.offset).inserted else {
                continue
            }
            nameBytes.removeSubrange(top.nameCount...)
            nameBytes.append(contentsOf: child.label.utf8)
            visit(entry) { String(decoding: nameBytes, as: UTF8.self) }
            stack.append((entry, nameBytes.count, 0))
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
