//
//  StringTable.swift
//  MachOKit
//
//  Created by p-x9 on 2025/02/02
//  
//

public protocol StringTable<Encoding>: Sequence<StringTableEntry> {
    associatedtype Encoding: _UnicodeEncoding

    /// Returns the string entry located at the specified offset within the string table.
    ///
    /// - Parameter offset: The byte offset from the start of the string table.
    /// - Returns: A `StringTableEntry` containing the string and its offset,
    ///            or `nil` if the offset is out of bounds or invalid.
    func string(at offset: Int) -> Element?
}
