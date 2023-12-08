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
