//
//  ExportTrieEntry.swift
//
//
//  Created by p-x9 on 2023/12/04.
//
//

import Foundation

public typealias ExportTrieEntry = TrieNode<ExportTrieNodeContent>

public struct ExportTrieNodeContent {
    public var flags: ExportSymbolFlags? // null when terminalSize == 0

    public var ordinal: UInt?
    public var importedName: String?

    public var stub: UInt?
    public var resolver: UInt?

    public var symbolOffset: UInt?
}

// https://opensource.apple.com/source/dyld/dyld-132.13/launch-cache/MachOTrie.hpp
// https://opensource.apple.com/source/ld64/ld64-253.9/src/other/dyldinfo.cpp.auto.html
extension ExportTrieNodeContent: TrieNodeContent {
    public static func read(
        basePointer: UnsafePointer<UInt8>,
        trieSize _: Int,
        nextOffset: inout Int
    ) -> ExportTrieNodeContent? {
        var content: Self = .init()

        let (flagsRaw, ulebOffset) = basePointer
            .advanced(by: nextOffset)
            .readULEB128()
        nextOffset += ulebOffset

        let flags = ExportSymbolFlags(rawValue: ExportSymbolFlags.RawValue(flagsRaw))
        content.flags = flags

        if flags.contains(.reexport) {
            let (value, ulebOffset) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebOffset

            content.ordinal = value

            let (string, stringOffset) = basePointer
                .advanced(by: nextOffset)
                .readString()
            nextOffset += stringOffset

            content.importedName = string
        } else if flags.contains(.stub_and_resolver) {
            let (stub, ulebOffset) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebOffset

            let (resolver, ulebOffset2) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebOffset2

            content.stub = stub
            content.resolver = resolver
        } else {
            let (value, ulebOffset) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebOffset

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
