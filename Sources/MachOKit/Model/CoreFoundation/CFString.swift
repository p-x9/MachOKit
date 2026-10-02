//
//  CFString.swift
//  MachOKit
//
//  Created by p-x9 on 2025/02/01
//  
//

import Foundation
import MachOKitC

public protocol CFStringProtocol: Sendable {
    /// The unslid virtual memory address of this record.
    var address: UInt64 { get }

    /// The byte offset of the `_ptr` field within the record layout.
    var _stringPointerOffset: Int { get }

    /// Offset at which string data is stored
    var stringAddress: Int { get }
    /// Number (in terms of UTF-16 code pairs) of Unicode characters in a string.
    var stringSize: Int { get }

    /// A Boolean value that indicates whether the String data is stored in unicode or not.
    var isUnicode: Bool { get }
    /// A Boolean value that indicates whether the String data is stored in 8-bit or not.
    var isEightBit: Bool { get }
    
    /// Obtain a stored string as a `Swift.String`
    /// - Parameter machO: MachOFile to which `self` belongs
    /// - Returns: stored string
    func string(in machO: MachOFile) -> String?

    /// Obtain a stored string as a `Swift.String`
    /// - Parameter machO: MachOImage to which `self` belongs
    /// - Returns: stored string
    func string(in machO: MachOImage) -> String?
}

public struct CFString64: LayoutWrapper, CFStringProtocol {
    public typealias Layout = CF_CONST_STRING64

    public var layout: Layout

    /// The unslid virtual memory address of this record.
    public var address: UInt64

    public init(layout: Layout, address: UInt64) {
        self.layout = layout
        self.address = address
    }
}

public struct CFString32: LayoutWrapper, CFStringProtocol {
    public typealias Layout = CF_CONST_STRING32

    public var layout: Layout

    /// The unslid virtual memory address of this record.
    public var address: UInt64

    public init(layout: Layout, address: UInt64) {
        self.layout = layout
        self.address = address
    }
}

extension CFString64 {
    public var _stringPointerOffset: Int {
        layoutOffset(of: \._ptr)
    }

    public var stringAddress: Int {
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
    public var _stringPointerOffset: Int {
        layoutOffset(of: \._ptr)
    }

    public var stringAddress: Int {
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
        guard let (file, offset) = fileAndOffset(in: machO) else { return nil }

        let byteCount = stringSize * (isUnicode ? MemoryLayout<UInt16>.size : 1)
        guard let data = try? file.readData(offset: offset, length: byteCount) else {
            return nil
        }
        return String(bytes: data, encoding: isUnicode ? .utf16LittleEndian : .utf8)
    }

    public func string(in machO: MachOImage) -> String? {
        guard let ptr = UnsafeRawPointer(bitPattern: UInt(stringAddress)) else {
            return nil
        }

        if isUnicode {
            let data = Data(bytes: ptr, count: numericCast(stringSize) * numericCast(MemoryLayout<UInt16/*UniChar*/>.size))
            return String(bytes: data, encoding: .utf16LittleEndian)
        } else {
            return .init(
                cString: ptr.assumingMemoryBound(to: CChar.self),
                encoding: .ascii
            )
        }
    }
}

private extension CFStringProtocol {
    func fileAndOffset(in machO: MachOFile) -> (MachOFile.File, Int)? {
        if machO.isLoadedFromDyldCache {
            guard let cache = machO.cache else { return nil }
            return fileAndOffset(in: cache)
        }
        guard let offset = machO.fileOffset(of: numericCast(stringAddress)) else {
            return nil
        }
        return (machO.fileHandle, machO.headerStartOffset + numericCast(offset))
    }

    func fileAndOffset(in cache: DyldCache) -> (MachOFile.File, Int)? {
        guard let record = try? cache.locateValue({ $0.fileOffset(of: address) }),
              let target = record.cache.resolveOptionalRebase(
                  at: record.value + UInt64(_stringPointerOffset)
              ),
              let located = try? cache.locateValue({ $0.fileOffset(of: target) }) else {
            return nil
        }
        return (located.cache.fileHandle, numericCast(located.value))
    }
}

extension CFStringProtocol {
    @available(*, deprecated, renamed: "stringAddress")
    public var stringOffset: Int {
        stringAddress
    }
}
