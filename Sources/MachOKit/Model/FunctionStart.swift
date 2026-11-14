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

    /// Creates a function start with the offset described by ``offset``.
    public init(offset: UInt) {
        self.offset = offset
    }
}

extension FunctionStart {
    internal static func readNext(
        basePointer: UnsafePointer<UInt8>,
        functionStartsSize: Int,
        lastFunctionOffset: UInt,
        nextOffset: inout Int
    ) -> FunctionStart? {
        guard nextOffset < functionStartsSize else { return nil }

        guard let additionalOffset = basePointer.readULEB128(at: &nextOffset, size: functionStartsSize) else {
            return nil
        }

        return .init(offset: lastFunctionOffset &+ additionalOffset)
    }
}
