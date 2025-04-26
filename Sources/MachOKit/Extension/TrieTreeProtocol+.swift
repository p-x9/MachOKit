//
//  TrieTreeProtocol+.swift
//  MachOKit
//
//  Created by p-x9 on 2024/11/20
//  
//

import Foundation

extension TrieTreeProtocol where Content == ExportTrieNodeContent {
    public var exportedSymbols: [ExportedSymbol] {
        guard let root = first(where: { _ in true }) else {
            return []
        }
        var result: [(String, Content)] = []
        _recurseTrie(currentName: "", entry: root, result: &result)
        return result
            .map {
                name, content in
                let symbolOffset: Int? = if let symbolOffset = content.symbolOffset {
                    .init(bitPattern: symbolOffset)
                } else { nil }
                return .init(
                    name: name,
                    offset: symbolOffset,
                    flags: content.flags ?? [],
                    ordinal: content.ordinal,
                    importedName: content.importedName,
                    stub: content.stub,
                    resolverOffset: content.resolver
                )
            }
    }

    public func search(by key: String) -> ExportedSymbol? {
        guard let (_, content) = _search(by: key) else {
            return nil
        }
        let symbolOffset: Int? = if let symbolOffset = content.symbolOffset {
            .init(bitPattern: symbolOffset)
        } else { nil }

        return .init(
            name: key,
            offset: symbolOffset,
            flags: content.flags ?? [],
            ordinal: content.ordinal,
            importedName: content.importedName,
            stub: content.stub,
            resolverOffset: content.resolver
        )
    }

    public func search(byKeyPrefix prefix: String) -> [ExportedSymbol] {
        let found = _search(byKeyPrefix: prefix)
        return found.compactMap {
            let content = $0.content
            let symbolOffset: Int? = if let symbolOffset = content.symbolOffset {
                .init(bitPattern: symbolOffset)
            } else { nil }

            return .init(
                name: $0.name,
                offset: symbolOffset,
                flags: content.flags ?? [],
                ordinal: content.ordinal,
                importedName: content.importedName,
                stub: content.stub,
                resolverOffset: content.resolver
            )
        }
    }
}

extension TrieTreeProtocol where Content == DylibsTrieNodeContent {
    public var dylibIndices: [DylibIndex] {
        guard let root = first(where: { _ in true }) else {
            return []
        }
        var result: [(String, Content)] = []
        _recurseTrie(currentName: "", entry: root, result: &result)
        return result.map {
            .init(name: $0, index: $1.index)
        }
    }

    public func search(by key: String) -> DylibIndex? {
        guard let (_, content) = _search(by: key) else {
            return nil
        }
        return.init(name: key, index: content.index)
    }

    public func search(byKeyPrefix prefix: String) -> [DylibIndex] {
        let found = _search(byKeyPrefix: prefix)
        return found.compactMap {
            return .init(name: $0.name, index: $0.content.index)
        }
    }
}

extension TrieTreeProtocol where Content == ProgramsTrieNodeContent {
    public var programOffsets: [ProgramOffset] {
        guard let root = first(where: { _ in true }) else {
            return []
        }
        var result: [(String, Content)] = []
        _recurseTrie(currentName: "", entry: root, result: &result)
        return result.map {
            .init(name: $0, offset: $1.offset)
        }
    }

    public func search(by key: String) -> ProgramOffset? {
        guard let (_, content) = _search(by: key) else {
            return nil
        }
        return.init(name: key, offset: content.offset)
    }

    public func search(byKeyPrefix prefix: String) -> [ProgramOffset] {
        let found = _search(byKeyPrefix: prefix)
        return found.compactMap {
            return .init(name: $0.name, offset: $0.content.offset)
        }
    }
}
