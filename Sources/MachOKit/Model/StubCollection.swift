//
//  StubCollection.swift
//  MachOKit
//

import Foundation

/// A raw-backed collection of entries in an `S_SYMBOL_STUBS` section.
public struct StubCollection: Sendable {
    /// The exact contents of the section.
    public let rawData: Data

    /// The unslid virtual memory address of the section.
    public let address: UInt64

    /// The size of each stub, from the section's `reserved2` field.
    public let entrySize: Int

    /// The indirect-symbol-table index corresponding to the first stub.
    public let indirectSymbolIndex: Int

    /// The architecture used to decode each stub.
    public let cpuType: CPUType?

    init(
        rawData: Data,
        address: UInt64,
        entrySize: Int,
        indirectSymbolIndex: Int,
        cpuType: CPUType?
    ) {
        self.rawData = rawData
        self.address = address
        self.entrySize = entrySize
        self.indirectSymbolIndex = indirectSymbolIndex
        self.cpuType = cpuType
    }

    /// Bytes at the end of the section that do not form a complete stub.
    public var trailingData: Data {
        rawData.subdata(in: endIndex * entrySize ..< rawData.count)
    }
}

extension StubCollection: RandomAccessCollection {
    public var startIndex: Int { 0 }

    public var endIndex: Int { rawData.count / entrySize }

    public subscript(position: Int) -> Stub {
        precondition(indices.contains(position), "Stub index out of range")
        let offset = position * entrySize
        let rawData = self.rawData.subdata(in: offset ..< offset + entrySize)
        let address = address + UInt64(offset)
        return .init(
            rawData: rawData,
            address: address,
            indirectSymbolIndex: indirectSymbolIndex + position,
            branch: StubDecoder.decode(
                rawData,
                address: address,
                cpuType: cpuType
            )
        )
    }
}
