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
        self = withUnsafePointer(to: &buffer.0) {
            let data = Data(bytes: $0, count: 16) + [0]
            return String(cString: data)!
        }
    }
}

extension String {
    typealias CCharTuple32 = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)

    init(tuple: CCharTuple32) {
        var buffer = tuple
        self = withUnsafePointer(to: &buffer.0) {
            let data = Data(bytes: $0, count: 32) + [0]
            return String(cString: data)!
        }
    }
}

extension String {
    init?(cString data: Data) {
        guard !data.isEmpty else { return nil }
        self = data.withUnsafeBytes {
            let ptr = $0.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
    }
}
