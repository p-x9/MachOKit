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
        var buffer = tuple
        self = withUnsafePointer(to: &buffer.0) { String(cString: $0) }
    }
}
