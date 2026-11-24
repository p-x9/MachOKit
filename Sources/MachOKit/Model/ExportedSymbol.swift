//
//  ExportedSymbol.swift
//
//
//  Created by p-x9 on 2023/12/11.
//
//

import Foundation

public struct ExportedSymbol: Sendable {
    public var name: String
    /// Symbol offset from start of mach header (`MachO`)
    /// Symbol offset from start of file (`MachOFile`)
    public var offset: Int?

    public var flags: ExportSymbolFlags

    public var ordinal: UInt?
    public var importedName: String?

    public var stub: UInt?
    public var resolverOffset: UInt?

    public var functionVariantTableIndex: UInt?

    /// Creates an exported symbol with its flags and optional export information.
    public init(
        name: String,
        offset: Int? = nil,
        flags: ExportSymbolFlags,
        ordinal: UInt? = nil,
        importedName: String? = nil,
        stub: UInt? = nil,
        resolverOffset: UInt? = nil,
        functionVariantTableIndex: UInt? = nil
    ) {
        self.name = name
        self.offset = offset
        self.flags = flags
        self.ordinal = ordinal
        self.importedName = importedName
        self.stub = stub
        self.resolverOffset = resolverOffset
        self.functionVariantTableIndex = functionVariantTableIndex
    }
}

extension ExportedSymbol {
    // [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/66c652a1f1f6b7b5266b8bbfd51cb0965d67cc44/common/MachOLoaded.cpp#L258)
    public func resolver(for machO: MachOImage) -> (@convention(c) () -> UInt)? {
        guard let resolverOffset else { return nil }
        return autoBitCast(
            machO.ptr.advanced(by: numericCast(resolverOffset))
        )
    }
}
