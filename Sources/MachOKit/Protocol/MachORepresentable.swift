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

    var rebaseOperations: RebaseOperations? { get }
    var bindOperations: BindOperations? { get }
    var weakBindOperations: BindOperations? { get }
    var lazyBindOperations: BindOperations? { get }
    var exportTrieEntries: ExportTrieEntries? { get }

    var exportedSymbols: [ExportedSymbol] { get }
    var bindingSymbols: [BindingSymbol] { get }
}
