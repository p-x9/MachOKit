//
//  StringTable.swift
//  MachOKit
//
//  Created by p-x9 on 2025/02/02
//  
//

public protocol StringTable<Encoding>: Sequence<StringTableEntry> {
    associatedtype Encoding: _UnicodeEncoding
}
