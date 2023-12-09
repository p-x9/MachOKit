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

    let terminalSize: UInt8
    var flags: ExportSymbolFlags? // null when terminalSize == 0

    var ordinal: UInt?
    var importedName: String?
    var symbolOffset: UInt?

    var children: [Child]
}

extension ExportTrieEntry: CustomStringConvertible {
    public var description: String {
        var text = ""

        text += "terminalSize: \(terminalSize)\n"
        if let flags {
            text += "flags: \(flags.bits)\n"
            if let kind = flags.kind {
                text += "kind: \(kind)\n"
            }
        }
        if let ordinal {
            text += "ordinal: \(ordinal)\n"
        }
        if let importedName {
            text += "importedName: \(importedName)\n"
        }
        if let symbolOffset {
            text += "symbolOffset: \(symbolOffset)\n"
        }

        let children = children
            .lazy
            .map(\.description)
            .map { "    - " + $0 }
        text += "children:\n"
        text += "\(children.joined(separator: "\n"))"

        return text
    }
}

extension ExportTrieEntry.Child: CustomStringConvertible {
    public var description: String {
        "label: \"\(label)\", offset: \(offset)"
    }
}

// https://opensource.apple.com/source/dyld/dyld-132.13/launch-cache/MachOTrie.hpp
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
            } else {
                let (value, ulebOffset) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebOffset

                entry.symbolOffset = value
            }

            if flags.contains(.stub_and_resolver) || flags.contains(.static_resolver) {
                let (string, stringOffset) = basePointer
                    .advanced(by: nextOffset)
                    .readString()
                nextOffset += stringOffset

                entry.importedName = string
            }
        }

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

        print("child", childrenOffset)
        nextOffset = childrenOffset

        return entry
    }
}
