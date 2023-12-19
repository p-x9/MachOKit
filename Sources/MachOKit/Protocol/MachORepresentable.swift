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

    /// A boolean value that indicates whether MachO is a 64-bit architecture.
    var is64Bit: Bool { get }

    /// Size of MachO header. [byte]
    var headerSize: Int { get }

    /// MachO header
    var header: MachHeader { get }

    /// Sequence of load commands
    var loadCommands: LoadCommands { get }

    /// List of runpaths
    var rpaths: [String] { get }
    /// List of depended dynamic libraries
    var dependencies: [Dylib] { get }

    /// List of segments
    var segments: [any SegmentCommandProtocol] { get }
    /// Sequence of 64-bit architecture segments
    var segments64: AnySequence<SegmentCommand64> { get }
    /// Sequence of 32-bit architecture segments
    var segments32: AnySequence<SegmentCommand> { get }

    /// List of sections in all segments
    var sections: [any SectionProtocol] { get }
    /// List of sections in 64-bit architecture segments
    var sections64: [Section64] { get }
    /// List of sections in 32-bit architecture segments
    var sections32: [Section] { get }

    /// Sequence of symbols
    var symbols: AnySequence<Symbol> { get }
    /// Sequence of 64-bit architecture symbols
    var symbols64: Symbols64? { get }
    /// Sequence of 32-bit architecture symbols
    var symbols32: Symbols? { get }

    /// Sequence of symbol strings.
    /// (symbol string table)
    var symbolStrings: Strings? { get }

    /// Sequence of strings in `__TEXT, __cstring` section
    var cStrings: Strings? { get }

    /// Sequence of all string tables in this MachO
    ///
    /// Symbol string table is not included.
    var allCStringTables: [Strings] { get }

    /// Sequence of all strings in this MachO
    ///
    /// Symbol strings is not included.
    var allCStrings: [String] { get }

    var rebaseOperations: RebaseOperations? { get }
    var bindOperations: BindOperations? { get }
    var weakBindOperations: BindOperations? { get }
    var lazyBindOperations: BindOperations? { get }
    var exportTrieEntries: ExportTrieEntries? { get }

    var exportedSymbols: [ExportedSymbol] { get }
    var bindingSymbols: [BindingSymbol] { get }
    var weakBindingSymbols: [BindingSymbol] { get }
    var lazyBindingSymbols: [BindingSymbol] { get }
    var rebases: [Rebase] { get }
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

    public var weakBindingSymbols: [BindingSymbol] {
        guard let weakBindOperations else {
            return []
        }
        return weakBindOperations.bindings(is64Bit: is64Bit)
    }

    public var lazyBindingSymbols: [BindingSymbol] {
        guard let lazyBindOperations else {
            return []
        }
        return lazyBindOperations.bindings(is64Bit: is64Bit)
    }

    public var rebases: [Rebase] {
        guard let rebaseOperations else {
            return []
        }
        return rebaseOperations.rebases(is64Bit: is64Bit)
    }
}
