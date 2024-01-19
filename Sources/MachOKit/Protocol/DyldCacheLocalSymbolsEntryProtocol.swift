//
//  DyldCacheLocalSymbolsEntryProtocol.swift
//
//
//  Created by p-x9 on 2024/01/20.
//  
//

import Foundation

public protocol DyldCacheLocalSymbolsEntryProtocol {
    var dylibOffset: Int { get }
    var nlistStartIndex: Int { get }
    var nlistCount: Int { get }
}
