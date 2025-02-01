//
//  CFString.swift
//  MachOKit
//
//  Created by p-x9 on 2025/02/01
//  
//

import Foundation
import MachOKitC

public protocol CFStringProtocol {
    var stringOffset: Int { get }
    var stringSize: Int { get }

    var isUnicode: Bool { get }
    var isEightBit: Bool { get }

    func string(in machO: MachOFile) -> String?
    func string(in machO: MachOImage) -> String?
}

public struct CFString64: LayoutWrapper, CFStringProtocol {
    public typealias Layout = CF_CONST_STRING64

    public var layout: Layout
}

public struct CFString32: LayoutWrapper, CFStringProtocol {
    public typealias Layout = CF_CONST_STRING32

    public var layout: Layout
}

extension CFString64 {
    public var stringOffset: Int {
        numericCast(layout._ptr & 0x7ffffffff)
    }

    public var stringSize: Int {
        numericCast(layout._length)
    }

    // ref: https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFString.c#L208C1-L212C3
    /* !!! Note: Constant CFStrings use the bit patterns:
    C8 (11001000 = default allocator, not inline, not freed contents; 8-bit; has NULL byte; doesn't have length; is immutable)
    D0 (11010000 = default allocator, not inline, not freed contents; Unicode; is immutable)
    The bit usages should not be modified in a way that would effect these bit patterns.
    */
    public var isUnicode: Bool {
        layout._base._cfinfo.0 == 0xD0 // FIXME: consider byte swapped environment (CF_INFO_BITS)
    }

    public var isEightBit: Bool {
        layout._base._cfinfo.0 == 0xC8
    }
}

extension CFString32 {
    public var stringOffset: Int {
        numericCast(layout._ptr)
    }

    public var stringSize: Int {
        numericCast(layout._length)
    }

    public var isUnicode: Bool {
        layout._base._cfinfo.0 == 0xD0
    }

    public var isEightBit: Bool {
        layout._base._cfinfo.0 == 0xC8
    }
}

extension CFStringProtocol {
    public func string(in machO: MachOFile) -> String? {
        let offset = machO.headerStartOffset + stringOffset
        if isUnicode {
            let data = machO.fileHandle.readData(
                offset: UInt64(offset),
                size: numericCast(stringSize) * numericCast(MemoryLayout<UniChar>.size)
            )
            return String(bytes: data, encoding: .utf16LittleEndian)
        } else {
            return machO.fileHandle.readString(
                offset: UInt64(offset),
                size: stringSize
            )
        }
    }

    public func string(in machO: MachOImage) -> String? {
        guard let ptr = UnsafeRawPointer(bitPattern: UInt(stringOffset)) else {
            return nil
        }

        if isUnicode {
            let data = Data(bytes: ptr, count: numericCast(stringSize) * numericCast(MemoryLayout<UniChar>.size))
            return String(bytes: data, encoding: .utf16LittleEndian)
        } else {
            return .init(
                cString: ptr.assumingMemoryBound(to: CChar.self),
                encoding: .ascii
            )
        }
    }
}
