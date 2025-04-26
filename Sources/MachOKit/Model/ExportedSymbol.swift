//
//  ExportedSymbol.swift
//  
//
//  Created by p-x9 on 2023/12/11.
//  
//

import Foundation

public struct ExportedSymbol {
    public var name: String
    /// Symbol offset from start of mach header (`MachO`)
    /// Symbol offset from start of file (`MachOFile`)
    public var offset: Int?

    public var flags: ExportSymbolFlags

    public var ordinal: UInt?
    public var importedName: String?

    public var stub: UInt?
    public var resolverOffset: UInt?
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
