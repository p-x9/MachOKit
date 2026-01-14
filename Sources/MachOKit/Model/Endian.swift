//
//  Endian.swift
//  MachOKit
//
//  Created by p-x9 on 2025/07/09
//
//

import CoreFoundation

public enum Endian: Sendable {
    case little
    case big
}

extension Endian {
    public static var current: Endian {
        switch CFByteOrderGetCurrent() {
        case numericCast(CFByteOrderLittleEndian.rawValue):
            return .little
        case numericCast(CFByteOrderBigEndian.rawValue):
            return .big
        default:
            fatalError("Unexpected byte order value: \(CFByteOrderGetCurrent())")
        }
    }
}
