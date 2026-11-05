//
//  ObjCStubCollection.swift
//  MachOKit
//

import Foundation

/// A raw-backed collection of entries in an `__objc_stubs` section.
public struct ObjCStubCollection: Sendable {
    /// The recognized layout of entries in the section.
    public enum Layout: Sendable, Equatable {
        /// A 32-byte arm64 or arm64e Objective-C stub.
        case arm64Regular
        /// A 12-byte arm64 or arm64e Objective-C stub.
        case arm64Small
        /// A 32-byte arm64_32 Objective-C stub.
        case arm64_32Regular
        /// A 12-byte arm64_32 Objective-C stub.
        case arm64_32Small
        /// A 13-byte x86_64 Objective-C stub.
        case x86_64
        /// The entry layout could not be determined.
        case unknown
    }

    /// The exact contents of the section.
    public let rawData: Data

    /// The unslid virtual memory address of the section.
    public let address: UInt64

    /// The layout inferred from the architecture and the first entry.
    public let layout: Layout

    /// The architecture used to decode each stub.
    public let cpuType: CPUType?

    init(
        rawData: Data,
        address: UInt64,
        layout: Layout,
        cpuType: CPUType?
    ) {
        self.rawData = rawData
        self.address = address
        self.layout = layout
        self.cpuType = cpuType
    }

    /// The size of each entry, or `nil` when the layout is unknown.
    public var entrySize: Int? { layout.entrySize }

    /// Bytes that could not be divided into complete entries.
    ///
    /// This is the complete section when ``layout`` is ``Layout/unknown``.
    public var trailingData: Data {
        guard let entrySize else { return rawData }
        return rawData.subdata(in: endIndex * entrySize ..< rawData.count)
    }
}

extension ObjCStubCollection: RandomAccessCollection {
    public var startIndex: Int { 0 }

    public var endIndex: Int {
        guard let entrySize else { return 0 }
        return rawData.count / entrySize
    }

    public subscript(position: Int) -> ObjCStub {
        precondition(indices.contains(position), "Objective-C stub index out of range")
        let entrySize = layout.entrySize!
        let branchOffset = layout.branchOffset!
        let offset = position * entrySize
        let rawData = self.rawData.subdata(in: offset ..< offset + entrySize)
        let address = address + UInt64(offset)
        let branchData = rawData.subdata(in: branchOffset ..< rawData.count)
        return .init(
            stub: .init(
                rawData: rawData,
                address: address,
                indirectSymbolIndex: nil,
                branch: StubDecoder.decode(
                    branchData,
                    address: address + UInt64(branchOffset),
                    cpuType: cpuType
                )
            ),
            selectorReference: StubDecoder.selectorReference(
                in: rawData,
                stubAddress: address,
                cpuType: cpuType
            )
        )
    }
}

extension ObjCStubCollection.Layout {
    public var entrySize: Int? {
        switch self {
        case .arm64Regular, .arm64_32Regular: 32
        case .arm64Small, .arm64_32Small: 12
        case .x86_64: 13
        case .unknown: nil
        }
    }

    fileprivate var branchOffset: Int? {
        switch self {
        case .arm64Regular, .arm64Small, .arm64_32Regular, .arm64_32Small: 8
        case .x86_64: 7
        case .unknown: nil
        }
    }
}
