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
        self.init(
            cString: Mirror(reflecting: tuple).children.compactMap {
                $0.value as? CChar
            }
        )
    }
}