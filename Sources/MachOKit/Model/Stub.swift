//
//  Stub.swift
//  MachOKit
//

import Foundation

/// A decoded Mach-O symbol stub.
public struct Stub: Sendable, Equatable {
    /// The unslid virtual memory address of the stub.
    public let address: UInt64

    /// The size of the stub in bytes.
    public let size: Int

    /// The corresponding index in the indirect symbol table.
    ///
    /// This is `nil` for stubs that do not belong to an `S_SYMBOL_STUBS`
    /// section, such as entries in `__objc_stubs`.
    public let indirectSymbolIndex: Int?

    /// The destination encoded by the stub instructions.
    public let branch: Branch

    public init(
        address: UInt64,
        size: Int,
        indirectSymbolIndex: Int?,
        branch: Branch
    ) {
        self.address = address
        self.size = size
        self.indirectSymbolIndex = indirectSymbolIndex
        self.branch = branch
    }
}

extension Stub {
    /// The kind of destination encoded by a stub.
    public enum Branch: Sendable, Equatable {
        /// The stub loads its destination from a GOT or lazy pointer slot.
        case viaSlot(UInt64)

        /// The stub branches directly to this unslid virtual memory address.
        case direct(UInt64)

        /// The instruction sequence is not a supported stub pattern.
        case unknown
    }
}
