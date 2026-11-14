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
    @_spi(Support)
    public func readULEB128() -> (UInt, Int) {
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

    /// (value, size)
    @_spi(Support)
    public func readSLEB128() -> (Int, Int) {
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

        if shift < Int.bitWidth, byte & 0x40 != 0 {
            value |= ~0 << shift
        }

        return (value, offset)
    }
}

extension UnsafePointer<UInt8> {
    /// (value, size), or `nil` if truncated within `maxSize` or overflowing 64 bits
    ///
    /// Like ld64/dyld, values are decoded as 64-bit and truncated to `UInt` on 32-bit hosts.
    @_spi(Support)
    public func readULEB128(maxSize: Int) -> (UInt, Int)? {
        var value: UInt64 = 0
        var shift: UInt64 = 0
        var offset: Int = 0

        var byte: UInt8 = 0

        repeat {
            guard offset < maxSize, shift < 64 else { return nil }
            byte = advanced(by: offset).pointee

            let slice = UInt64(byte & 0x7F)
            guard (slice << shift) >> shift == slice else { return nil }

            value |= slice << shift
            shift += 7
            offset += 1
        } while byte >= 128

        return (UInt(truncatingIfNeeded: value), offset)
    }

    /// (value, size), or `nil` if truncated within `maxSize` or overflowing 64 bits
    ///
    /// Like ld64/dyld, values are decoded as 64-bit and truncated to `Int` on 32-bit hosts.
    @_spi(Support)
    public func readSLEB128(maxSize: Int) -> (Int, Int)? {
        var value: Int64 = 0
        var shift: UInt64 = 0
        var offset: Int = 0

        var byte: UInt8 = 0

        repeat {
            guard offset < maxSize, shift < 64 else { return nil }
            byte = advanced(by: offset).pointee

            // The last byte carries the sign in bit 6
            let slice = byte >= 128
                ? Int64(byte & 0x7F)
                : Int64(Int8(bitPattern: byte << 1) >> 1)
            guard (slice << shift) >> shift == slice else { return nil }

            value |= slice << shift
            shift += 7
            offset += 1
        } while byte >= 128

        return (Int(truncatingIfNeeded: value), offset)
    }
}

extension UnsafePointer<UInt8> {
    /// (string, size), or `nil` if not terminated within `maxSize`
    func readString(maxSize: Int) -> (String, Int)? {
        guard maxSize > 0,
              let terminator = memchr(self, 0, maxSize) else {
            return nil
        }
        let length = Int(bitPattern: terminator) - Int(bitPattern: self)
        let string = String(
            decoding: UnsafeBufferPointer(start: self, count: length),
            as: UTF8.self
        )

        return (string, length + 1)
    }
}

// Cursor variants: read at `offset` within a region of `size` bytes starting
// at `self`, advancing `offset` past the value on success.
extension UnsafePointer<UInt8> {
    func readULEB128(at offset: inout Int, size: Int) -> UInt? {
        guard let (value, length) = advanced(by: offset)
            .readULEB128(maxSize: size - offset) else {
            return nil
        }
        offset += length
        return value
    }

    func readSLEB128(at offset: inout Int, size: Int) -> Int? {
        guard let (value, length) = advanced(by: offset)
            .readSLEB128(maxSize: size - offset) else {
            return nil
        }
        offset += length
        return value
    }

    func readString(at offset: inout Int, size: Int) -> String? {
        guard let (string, length) = advanced(by: offset)
            .readString(maxSize: size - offset) else {
            return nil
        }
        offset += length
        return string
    }
}

extension UnsafePointer<CChar> {
    func readString() -> (String, Int) {
        let offset = Int(bitPattern: strchr(self, 0)) + 1 - Int(bitPattern: self)
        let string = String(cString: self)

        return (string, offset)
    }
}

extension UnsafePointer where Pointee: FixedWidthInteger {
    func findNullTerminator() -> UnsafePointer<Pointee> {
        var ptr = self
        while ptr.pointee != 0 {
            ptr = ptr.advanced(by: 1)
        }
        return ptr
    }

    func readString<Encoding: _UnicodeEncoding>(
        as encoding: Encoding.Type
    ) -> (String, Int) where Pointee == Encoding.CodeUnit {
        let nullTerminator = findNullTerminator()
        let offset = Int(bitPattern: nullTerminator) + MemoryLayout<Pointee>.size - Int(bitPattern: self)
        let string = String(decodingCString: self, as: Encoding.self)

        return (string, offset)
    }
}
