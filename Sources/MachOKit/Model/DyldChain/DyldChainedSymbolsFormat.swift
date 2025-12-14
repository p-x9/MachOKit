//
//  DyldChainedSymbolsFormat.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

public enum DyldChainedSymbolsFormat: UInt32, Sendable {
    case uncompressed
    case zlibCompressed
}
