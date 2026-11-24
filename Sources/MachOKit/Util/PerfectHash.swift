//
//  PerfectHash.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/20
//
//

import Foundation

// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/PerfectHash.cpp
internal enum PerfectHash {}

extension PerfectHash {

    /// lookup8.c, by Bob Jenkins, January 4 1997, Public Domain.
    ///
    /// Hash a variable-length key into a 64-bit value.
    /// - Parameters:
    ///   - key: the key
    ///   - level: the previous hash, or an arbitrary value
    /// - Returns: hash value
    static func lookup8(
        _ key: UnsafeRawBufferPointer,
        level: UInt64
    ) -> UInt64 {
        var a: UInt64 = level
        var b: UInt64 = level
        var c: UInt64 = 0x9e3779b97f4a7c13 // the golden ratio; an arbitrary value

        var k = 0
        var len = key.count

        // handle most of the key
        while len >= 24 {
            a &+= word(key, at: k)
            b &+= word(key, at: k + 8)
            c &+= word(key, at: k + 16)
            mix64(&a, &b, &c)
            k += 24
            len -= 24
        }

        // handle the last 23 bytes
        c &+= UInt64(key.count)
        for i in 0 ..< len {
            let byte = UInt64(key[k + i])
            switch i {
            case 0 ..< 8:
                a &+= byte << (8 * i)
            case 8 ..< 16:
                b &+= byte << (8 * (i - 8))
            default:
                // the first byte of c is reserved for the length
                c &+= byte << (8 * (i - 15))
            }
        }
        mix64(&a, &b, &c)

        return c
    }

    static func lookup8(_ key: String, level: UInt64) -> UInt64 {
        var key = key
        return key.withUTF8 {
            lookup8(UnsafeRawBufferPointer($0), level: level)
        }
    }
}

extension PerfectHash {
    @inline(__always)
    private static func word(
        _ key: UnsafeRawBufferPointer,
        at offset: Int
    ) -> UInt64 {
        var value: UInt64 = 0
        for i in 0 ..< 8 {
            value |= UInt64(key[offset + i]) << (8 * i)
        }
        return value
    }

    @inline(__always)
    private static func mix64(
        _ a: inout UInt64,
        _ b: inout UInt64,
        _ c: inout UInt64
    ) {
        a &-= b; a &-= c; a ^= (c >> 43)
        b &-= c; b &-= a; b ^= (a << 9)
        c &-= a; c &-= b; c ^= (b >> 8)
        a &-= b; a &-= c; a ^= (c >> 38)
        b &-= c; b &-= a; b ^= (a << 23)
        c &-= a; c &-= b; c ^= (b >> 5)
        a &-= b; a &-= c; a ^= (c >> 35)
        b &-= c; b &-= a; b ^= (a << 49)
        c &-= a; c &-= b; c ^= (b >> 11)
        a &-= b; a &-= c; a ^= (c >> 12)
        b &-= c; b &-= a; b ^= (a << 18)
        c &-= a; c &-= b; c ^= (b >> 22)
    }
}
