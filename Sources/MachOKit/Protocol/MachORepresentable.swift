//
//  MachORepresentable.swift
//
//
//  Created by p-x9 on 2023/12/13.
//  
//

import Foundation

public protocol MachORepresentable {
    associatedtype LoadCommands: LoadCommandsProtocol
    associatedtype Symbols64: Sequence<Symbol>
    associatedtype Symbols: Sequence<Symbol>
    associatedtype RebaseOperations: Sequence<RebaseOperation>
    associatedtype BindOperations: Sequence<BindOperation>
    associatedtype ExportTrieEntries: Sequence<ExportTrieEntry>
    associatedtype Strings: Sequence<StringTableEntry>

    var is64Bit: Bool { get }
    var headerSize: Int { get }

    var header: MachHeader { get }
    var loadCommands: LoadCommands { get }

    var rpaths: [String] { get }
    var dependencies: [Dylib] { get }

    var segments: [any SegmentCommandProtocol] { get }
    var segments64: AnySequence<SegmentCommand64> { get }
    var segments32: AnySequence<SegmentCommand> { get }

    var sections: [any SectionProtocol] { get }
    var sections64: [Section64] { get }
    var sections32: [Section] { get }

    var symbols: AnySequence<Symbol> { get }
    var symbols64: Symbols64? { get }
    var symbols32: Symbols? { get }

    var symbolStrings: Strings? { get }

    var cStrings: Strings? { get }
    var allCStringTables: [Strings] { get }
    var allCStrings: [String] { get }

    var rebaseOperations: RebaseOperations? { get }
    var bindOperations: BindOperations? { get }
    var weakBindOperations: BindOperations? { get }
    var lazyBindOperations: BindOperations? { get }
    var exportTrieEntries: ExportTrieEntries? { get }

    var exportedSymbols: [ExportedSymbol] { get }
    var bindingSymbols: [BindingSymbol] { get }
}

extension MachORepresentable {
    public var segments: [any SegmentCommandProtocol] {
        if is64Bit {
            Array(segments64)
        } else {
            Array(segments32)
        }
    }

    public var segments64: AnySequence<SegmentCommand64> {
        loadCommands.infos(of: LoadCommand.segment64)
    }

    public var segments32: AnySequence<SegmentCommand> {
        loadCommands.infos(of: LoadCommand.segment)
    }
}

extension MachORepresentable {
    public var sections: [any SectionProtocol] {
        if is64Bit {
            sections64
        } else {
            sections32
        }
    }
}

extension MachORepresentable {
    public var symbols: AnySequence<Symbol> {
        if is64Bit, let symbols64 {
            AnySequence(symbols64)
        } else if let symbols32 {
            AnySequence(symbols32)
        } else {
            AnySequence([])
        }
    }
}

extension MachORepresentable {
    public var exportedSymbols: [ExportedSymbol] {
        guard let exportTrieEntries else {
            return []
        }
        return exportTrieEntries.exportedSymbols
    }

    public var bindingSymbols: [BindingSymbol] {
        guard let bindOperations else {
            return []
        }
        return bindOperations.bindings(is64Bit: is64Bit)
    }
}
