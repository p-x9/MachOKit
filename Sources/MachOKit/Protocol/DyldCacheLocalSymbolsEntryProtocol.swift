//
//  DyldCacheLocalSymbolsEntryProtocol.swift
//
//
//  Created by p-x9 on 2024/01/20.
//  
//

import Foundation

public protocol DyldCacheLocalSymbolsEntryProtocol: Sendable {
    /// Offset in cache buffer of start of dylib
    var dylibOffset: Int { get }

    /// Start index of locals for this dylib
    var nlistStartIndex: Int { get }

    /// Number of local symbols for this dylib
    var nlistCount: Int { get }
}

extension DyldCacheLocalSymbolsEntryProtocol {
    public var nlistRange: Range<Int> {
        nlistStartIndex ..< nlistStartIndex + nlistCount
    }
}
