//
//  ExportTrieEntry.swift
//
//
//  Created by p-x9 on 2023/12/04.
//
//

import Foundation

public typealias ExportTrieEntry = TrieNode<ExportTrieNodeContent>

public struct ExportTrieNodeContent: Sendable {
    public var flags: ExportSymbolFlags? // null when terminalSize == 0

    public var ordinal: UInt?
    public var importedName: String?

    public var stub: UInt?
    public var resolver: UInt?

    public var functionVariantTableIndex: UInt?

    public var symbolOffset: UInt?

    /// Creates export trie content. Omitted fields remain absent.
    public init(
        flags: ExportSymbolFlags? = nil,
        ordinal: UInt? = nil,
        importedName: String? = nil,
        stub: UInt? = nil,
        resolver: UInt? = nil,
        functionVariantTableIndex: UInt? = nil,
        symbolOffset: UInt? = nil
    ) {
        self.flags = flags
        self.ordinal = ordinal
        self.importedName = importedName
        self.stub = stub
        self.resolver = resolver
        self.functionVariantTableIndex = functionVariantTableIndex
        self.symbolOffset = symbolOffset
    }
}

// https://opensource.apple.com/source/dyld/dyld-132.13/launch-cache/MachOTrie.hpp
// https://opensource.apple.com/source/ld64/ld64-253.9/src/other/dyldinfo.cpp.auto.html
extension ExportTrieNodeContent: TrieNodeContent {
    public static func read(
        basePointer: UnsafePointer<UInt8>,
        trieSize: Int,
        nextOffset: inout Int
    ) -> ExportTrieNodeContent? {
        var content: Self = .init()

        guard let flagsRaw = basePointer.readULEB128(at: &nextOffset, size: trieSize) else {
            return nil
        }

        guard let flagsRaw = ExportSymbolFlags.RawValue(exactly: flagsRaw) else {
            return nil
        }
        let flags = ExportSymbolFlags(rawValue: flagsRaw)
        content.flags = flags

        if flags.contains(.reexport) {
            guard let value = basePointer.readULEB128(at: &nextOffset, size: trieSize) else {
                return nil
            }

            content.ordinal = value

            guard let string = basePointer.readString(at: &nextOffset, size: trieSize) else {
                return nil
            }

            content.importedName = string
        } else if flags.contains(.stub_and_resolver) {
            guard let stub = basePointer.readULEB128(at: &nextOffset, size: trieSize) else {
                return nil
            }

            guard let resolver = basePointer.readULEB128(at: &nextOffset, size: trieSize) else {
                return nil
            }

            content.stub = stub
            content.resolver = resolver
        } else if flags.contains(.function_variant) {
            guard let symbolOffset = basePointer.readULEB128(at: &nextOffset, size: trieSize) else {
                return nil
            }
            guard let functionVariantTableIndex = basePointer.readULEB128(at: &nextOffset, size: trieSize) else {
                return nil
            }

            content.symbolOffset = symbolOffset
            content.functionVariantTableIndex = functionVariantTableIndex
        } else {
            guard let value = basePointer.readULEB128(at: &nextOffset, size: trieSize) else {
                return nil
            }

            content.symbolOffset = value
        }

        return content
    }
}

extension ExportTrieEntry: CustomStringConvertible {
    public var description: String {
        var text = ""

        text += "offset: \(offset)\n"
        text += "terminalSize: \(terminalSize)\n"

        if let content {
            if let flags = content.flags {
                text += "flags: \(flags.bits)\n"
                if let kind = flags.kind {
                    text += "kind: \(kind)\n"
                }
            }

            if let ordinal = content.ordinal {
                text += "ordinal: \(ordinal)\n"
            }
            if let importedName = content.importedName {
                text += "importedName: \(importedName)\n"
            }

            if let stub = content.stub {
                text += "stub: \(stub)\n"
            }
            if let resolver = content.resolver {
                text += "resolver: \(resolver)\n"
            }

            if let symbolOffset = content.symbolOffset {
                text += "symbolOffset: \(symbolOffset)\n"
            }
        }

        if !children.isEmpty {
            let children = children
                .lazy
                .enumerated()
                .map { "\($0)    - " + $1.description }
            text += "children(\(self.children.count)):\n"
            text += "\(children.joined(separator: "\n"))"
        }

        return text
    }
}

extension ExportTrieEntry.Child: CustomStringConvertible {
    public var description: String {
        "label: \"\(label)\", offset: \(offset)"
    }
}
