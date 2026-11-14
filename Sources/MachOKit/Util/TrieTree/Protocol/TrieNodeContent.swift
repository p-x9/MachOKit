//
//  TrieNodeContent.swift
//  
//
//  Created by p-x9 on 2024/07/05
//  
//

import Foundation

public protocol TrieNodeContent {
    static func read(
        basePointer: UnsafePointer<UInt8>,
        trieSize: Int,
        nextOffset: inout Int
    ) -> Self?
}
