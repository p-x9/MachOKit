//
//  IndirectSymbol.swift
//
//
//  Created by p-x9 on 2023/12/26.
//  
//

import Foundation

public struct IndirectSymbol {
    let _index: UInt32
}

extension IndirectSymbol {
    /// index of symbols
    public var index: Int {
        numericCast(_index)
    }
}
