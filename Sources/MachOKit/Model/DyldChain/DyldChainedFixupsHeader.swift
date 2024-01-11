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

extension DyldChainedFixupsHeader {
    public var swapped: Self {
        var layout = self.layout
        layout.fixups_version = layout.fixups_version.byteSwapped
        layout.starts_offset = layout.starts_offset.byteSwapped
        layout.imports_offset = layout.imports_offset.byteSwapped
        layout.symbols_offset = layout.symbols_offset.byteSwapped
        layout.imports_count = layout.imports_count.byteSwapped
        layout.imports_format = layout.imports_format.byteSwapped
        layout.symbols_format = layout.symbols_format.byteSwapped

        return .init(layout: layout)
    }
}
