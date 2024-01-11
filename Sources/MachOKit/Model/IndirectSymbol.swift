//
//  IndirectSymbol.swift
//
//
//  Created by p-x9 on 2023/12/26.
//  
//

import Foundation

public struct IndirectSymbol {
    let _value: UInt32
}

extension IndirectSymbol {
    /// index of symbols
    public var index: Int? {
        guard !isLocal, !isAbsolute else { return nil }
        return numericCast(_value)
    }

    /// INDIRECT_SYMBOL_LOCAL
    public var isLocal: Bool {
        _value & ~UInt32(INDIRECT_SYMBOL_ABS) == INDIRECT_SYMBOL_LOCAL
    }

    /// INDIRECT_SYMBOL_ABS
    public var isAbsolute: Bool {
        _value & UInt32(INDIRECT_SYMBOL_ABS) != 0
    }
}

extension IndirectSymbol: CustomStringConvertible {
    public var description: String {
        if isLocal && isAbsolute {
            "INDIRECT_SYMBOL_LOCAL & INDIRECT_SYMBOL_ABS"
        } else if isLocal {
            "INDIRECT_SYMBOL_LOCAL"
        } else if isAbsolute {
            "INDIRECT_SYMBOL_ABS"
        } else {
            "\(_value)"
        }
    }
}
