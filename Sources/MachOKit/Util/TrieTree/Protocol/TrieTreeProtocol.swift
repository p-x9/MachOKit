//
//  TrieTreeProtocol.swift
//
//
//  Created by p-x9 on 2024/10/06
//  
//

import Foundation

public protocol TrieTreeProtocol<Content>: Sequence where Element == TrieNode<Content> {
    associatedtype Content: TrieNodeContent
}
