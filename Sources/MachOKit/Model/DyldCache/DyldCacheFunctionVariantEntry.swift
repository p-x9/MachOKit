//
//  DyldCacheFunctionVariantEntry.swift
//  MachOKit
//
//  Created by p-x9 on 2025/05/12
//  
//

import Foundation
import MachOKitC

public struct DyldCacheFunctionVariantEntry: LayoutWrapper, Sendable {
    public typealias Layout = dyld_cache_function_variant_entry

    public var layout: Layout
}

extension DyldCacheFunctionVariantEntry {
    public var isPACSigned: Bool {
        layout.pacAuth != 0
    }

    public var sizeOfFunctionVariantTable: Int {
        numericCast(layout.functionVariantTableSizeDiv4) * 4
    }
}
