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
    func readULEB128() -> (Int, Int) {
        var value: Int = 0
        var shift: Int = 0
        var offset: Int = 0

        var byte: UInt8 = 0

        repeat {
            byte = advanced(by: offset).pointee

            value += Int(byte & 0x7F) << shift
            shift += 7
            offset += 1
        } while byte >= 128

        return (value, offset)
    }

    /// (value, size)
    func readSLEB128() -> (Int, Int) {
        var value: Int = 0
        var shift: UInt = 0
        var offset: Int = 0

        var byte: UInt8 = 0

        repeat {
            byte = advanced(by: offset).pointee

            value += Int(byte & 0x7F) << shift
            shift += 7
            offset += 1
        } while byte >= 128

        if byte & 0x40 != 0 {
            value |= -(1 << shift)
        }

        return (value, offset)
    }
}

extension UnsafePointer<UInt8> {
    func readString() -> (String, Int) {
        let offset = Int(bitPattern: strchr(self, 0)) + 1 - Int(bitPattern: self)
        let string = String(cString: self)

        return (string, offset)
    }
}
