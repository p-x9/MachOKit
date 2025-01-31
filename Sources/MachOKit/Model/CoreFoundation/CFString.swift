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
}

extension CFString32 {
    public var stringOffset: Int {
        numericCast(layout._ptr)
    }

    public var stringSize: Int {
        numericCast(layout._length)
    }
}

extension CFStringProtocol {
    public func string(in machO: MachOFile) -> String? {
        let offset = machO.headerStartOffset + stringOffset
        return machO.fileHandle.readString(
            offset: UInt64(offset),
            size: stringSize
        )
    }

    public func string(in machO: MachOImage) -> String? {
        guard let ptr = UnsafeRawPointer(bitPattern: UInt(stringOffset)) else {
            return nil
        }
        return .init(
            cString: ptr.assumingMemoryBound(to: CChar.self),
            encoding: .utf8
        )
    }
}
