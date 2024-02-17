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
    public let index: Int

    public var isNone: Bool {
        offset == DYLD_CHAINED_PTR_START_NONE
    }

    public var isMulti: Bool {
        offset & UInt16(DYLD_CHAINED_PTR_START_MULTI) > 0
    }
}
