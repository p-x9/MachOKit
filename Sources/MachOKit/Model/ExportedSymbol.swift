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

    var flags: ExportSymbolFlags

    var ordinal: UInt?
    var importedName: String?

    var stub: UInt?
    var resolverOffset: UInt?
}

extension ExportedSymbol {
    func resolver(for machO: MachOImage) -> (@convention(c) () -> UInt)? {
        guard let resolverOffset else { return nil }
        return autoBitCast(
            machO.ptr.advanced(by: numericCast(resolverOffset))
        )
    }
}
