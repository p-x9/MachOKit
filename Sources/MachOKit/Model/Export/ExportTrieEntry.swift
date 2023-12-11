//
//  ExportTrieEntry.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public struct ExportTrieEntry {
    public struct Child {
        let label: String
        let offset: UInt // offset from start of export (dyld_info_command.dyld_info_command + offset)
    }

    let offset: Int // offset from start of export

    let terminalSize: UInt8
    var flags: ExportSymbolFlags? // null when terminalSize == 0

    var ordinal: UInt?
    var importedName: String?

    var stub: UInt?
    var resolver: UInt?

    var symbolOffset: UInt?

    var children: [Child]
}

extension ExportTrieEntry: CustomStringConvertible {
    public var description: String {
        var text = ""

        text += "offset: \(offset)\n"
        text += "terminalSize: \(terminalSize)\n"
        if let flags {
            text += "flags: \(flags.bits)\n"
            if let kind = flags.kind {
                text += "kind: \(kind)\n"
            }
        }

        if let ordinal { text += "ordinal: \(ordinal)\n" }
        if let importedName { text += "importedName: \(importedName)\n" }

        if let stub { text += "stub: \(stub)\n" }
        if let resolver { text += "resolver: \(resolver)\n" }

        if let symbolOffset { text += "symbolOffset: \(symbolOffset)\n" }

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

// https://opensource.apple.com/source/dyld/dyld-132.13/launch-cache/MachOTrie.hpp
// https://opensource.apple.com/source/ld64/ld64-253.9/src/other/dyldinfo.cpp.auto.html
extension ExportTrieEntry {
    internal static func readNext(
        basePointer: UnsafePointer<UInt8>,
        exportSize: Int,
        nextOffset: inout Int
    ) -> ExportTrieEntry? {
        guard nextOffset < exportSize else { return nil }

        let terminalSize = basePointer.advanced(by: nextOffset).pointee
        nextOffset += MemoryLayout<UInt8>.size

        var entry = ExportTrieEntry(
            offset: nextOffset - 1,
            terminalSize: terminalSize,
            children: []
        )

        var childrenOffset = nextOffset + Int(terminalSize)

        if terminalSize != 0 {
            let (flagsRaw, ulebOffset) = basePointer
                .advanced(by: nextOffset)
                .readULEB128()
            nextOffset += ulebOffset

            let flags = ExportSymbolFlags(rawValue: ExportSymbolFlags.RawValue(flagsRaw))
            entry.flags = flags

            if flags.contains(.reexport) {
                let (value, ulebOffset) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebOffset

                entry.ordinal = value

                let (string, stringOffset) = basePointer
                    .advanced(by: nextOffset)
                    .readString()
                nextOffset += stringOffset

                entry.importedName = string
            } else if flags.contains(.stub_and_resolver) {
                let (stub, ulebOffset) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebOffset

                let (resolver, ulebOffset2) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebOffset2

                entry.stub = stub
                entry.resolver = resolver
            } else {
                let (value, ulebOffset) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebOffset

                entry.symbolOffset = value
            }
        }

        guard childrenOffset < exportSize else { return entry }

        let numberOfChildren = basePointer
            .advanced(by: childrenOffset)
            .pointee
        childrenOffset += MemoryLayout<UInt8>.size

        for _ in 0..<numberOfChildren {
            let (string, stringOffset) = basePointer
                .advanced(by: childrenOffset)
                .readString()
            childrenOffset += stringOffset

            let (value, ulebOffset) = basePointer
                .advanced(by: childrenOffset)
                .readULEB128()
            childrenOffset += ulebOffset

            let child = ExportTrieEntry.Child(label: string, offset: value)
            entry.children.append(child)
        }

        nextOffset = childrenOffset

        return entry
    }
}
