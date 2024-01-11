//
//  DyldChainedSymbolsFormat.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

public enum DyldChainedSymbolsFormat: UInt32 {
    case uncompressed
    case zlibCompressed
}

public struct DyldChainedPage {
    public let offset: UInt16

    public var isNone: Bool {
        offset == 0xFFFF // DYLD_CHAINED_PTR_START_NONE
    }

    public var isMulti: Bool {
        offset & 0x8000 > 0 // DYLD_CHAINED_PTR_START_MULTI
    }
}
