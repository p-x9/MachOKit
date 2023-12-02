//
//  UnsafePointer+.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

extension UnsafePointer<UInt8> {
    /// (value, size)
    func readULEB128() -> (UInt, Int) {
        var value: UInt = 0
        var shift: UInt = 0
        var offset: Int = 0

        var byte: UInt8 = 0

        repeat {
            byte = advanced(by: offset).pointee

            value += UInt(byte & 0x7F) << shift
            shift += 7
            offset += 1
        } while byte >= 128

        return (value, offset)
    }
}
