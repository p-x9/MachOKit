//
//  DyldChainedFixupsHeader.swift
//  
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation
import MachOKitC

public struct DyldChainedFixupsHeader: LayoutWrapper {
    public typealias Layout = dyld_chained_fixups_header

    public var layout: Layout

    public var importsFormat: DyldChainedImportFormat? {
        .init(rawValue: layout.imports_format)
    }

    public var symbolsFormat: DyldChainedSymbolsFormat? {
        .init(rawValue: layout.symbols_format)
    }
}
