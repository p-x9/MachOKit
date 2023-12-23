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
        self.init(cStringRaw: &buffer)
    }

    @inlinable
    init(cStringRaw: UnsafeRawPointer) {
        self.init(cString: cStringRaw.assumingMemoryBound(to: CChar.self))
    }
}
