//
//  DylibIndex.swift
//
//
//  Created by p-x9 on 2024/07/07
//  
//

import Foundation

/// Index/name pairs, obtained from the Dylibs trie, present in the dyld cache.
///
/// If an alias for dylib exists, there may be another element with an equal Index in trie.
public struct DylibIndex: Sendable {
    // Dylib name
    public let name: String
    /// Dylib index
    public let index: UInt32
}
