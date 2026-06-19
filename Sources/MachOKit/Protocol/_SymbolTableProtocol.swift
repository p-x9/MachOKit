//
//  _SymbolTableProtocol.swift
//  MachOKit
//
//  Created by p-x9 on 2026/06/19
//  
//

protocol _SymbolTableProtocol<Symbol> {
    associatedtype Symbol: SymbolProtocol
    associatedtype WrappedNlist: NlistProtocol

    var indices: Range<Int> { get }

    func wrappedNlist(at position: Int) -> WrappedNlist
    func offset(of nlist: WrappedNlist) -> Int
    func symbol(at position: Int, nlist: WrappedNlist) -> Symbol
}
