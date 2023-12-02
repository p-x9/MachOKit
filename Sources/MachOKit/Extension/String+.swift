//
//  String+.swift
//  
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

extension String {
    typealias CCharTuple16 = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)

    init(tuple: CCharTuple16) {
        self = Mirror(reflecting: tuple).children
            .compactMap {
                if let value = $0.value as? CChar,
                   value != 0 {
                    return value
                } else { return nil }
            }
            .map(UInt8.init)
            .map(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
}
