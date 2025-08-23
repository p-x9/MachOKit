//
//  FunctionStart.swift
//
//
//  Created by p-x9 on 2024/01/07.
//
//

import Foundation

public struct FunctionStart: Sendable {
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

        let (additionalOffset, size) = basePointer
            .advanced(by: nextOffset)
            .readULEB128()
        nextOffset += size

        return .init(offset: lastFunctionOffset + additionalOffset)
    }
}
