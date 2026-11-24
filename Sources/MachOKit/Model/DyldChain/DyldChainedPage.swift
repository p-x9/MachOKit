//
//  DyldChainedPage.swift
//
//
//  Created by p-x9 on 2024/02/17.
//  
//

import Foundation

public struct DyldChainedPage: Sendable {
    public let offset: UInt16
    public let index: Int

    /// Creates a chained page entry with its raw start offset and page index.
    public init(offset: UInt16, index: Int) {
        self.offset = offset
        self.index = index
    }

    public var isNone: Bool {
        offset == DYLD_CHAINED_PTR_START_NONE
    }

    public var isMulti: Bool {
        offset & UInt16(DYLD_CHAINED_PTR_START_MULTI) > 0
    }
}
