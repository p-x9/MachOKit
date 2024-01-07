//
//  FunctionStart.swift
//
//
//  Created by p-x9 on 2024/01/07.
//  
//

import Foundation

public struct FunctionStart {
    /// Offset from start of mach header (`MachO`)
    /// File offset from mach header (`MachOFile`)
    public let offset: UInt
}

extension FunctionStart {
    internal static func readNext(
        basePointer: UnsafePointer<UInt8>,
        functionStartsSize: Int,
        lastFunctionOffset: UInt,
        nextOffset: inout Int
    ) -> FunctionStart? {
        guard nextOffset < functionStartsSize else { return nil }

        var delta: UInt = 0
        var shift: UInt = 0
        var more = true

        var functionOffset = lastFunctionOffset

        repeat {
            let byte = basePointer
                .advanced(by: nextOffset)
                .pointee
            nextOffset += 1
            delta |= ((numericCast(byte) & 0x7F) << shift)
            shift += 7
            if ( byte < 0x80 ) {
                functionOffset += delta;
                more = false
            }
        } while more

        return .init(offset: functionOffset)
    }
}
