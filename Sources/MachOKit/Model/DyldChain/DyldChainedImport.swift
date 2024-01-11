//
//  DyldChainedImport.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation
import MachOKitC

public enum DyldChainedImport {
    case general(DyldChainedImportGeneral)
    case addend(DyldChainedImportAddend)
    case addend64(DyldChainedImportAddend64)

    public var info: any DyldChainedImportProtocol {
        switch self {
        case let .general(info): info
        case let .addend(info): info
        case let .addend64(info): info
        }
    }
}

public struct DyldChainedImportGeneral: DyldChainedImportProtocol {
    public typealias Layout = dyld_chained_import
    public var layout: Layout

    public var libraryOrdinal: Int {
        numericCast(layout.lib_ordinal)
    }

    public var isWeakImport: Bool {
        layout.weak_import != 0
    }

    public var nameOffset: Int {
        numericCast(layout.name_offset)
    }
}

public struct DyldChainedImportAddend: DyldChainedImportProtocol {
    public typealias Layout = dyld_chained_import_addend
    public var layout: Layout

    public var libraryOrdinal: Int {
        numericCast(layout.lib_ordinal)
    }

    public var isWeakImport: Bool {
        layout.weak_import != 0
    }

    public var nameOffset: Int {
        numericCast(layout.name_offset)
    }
}

public struct DyldChainedImportAddend64: DyldChainedImportProtocol {
    public typealias Layout = dyld_chained_import_addend64
    public var layout: Layout

    public var libraryOrdinal: Int {
        numericCast(layout.lib_ordinal)
    }

    public var isWeakImport: Bool {
        layout.weak_import != 0
    }

    public var nameOffset: Int {
        numericCast(layout.name_offset)
    }
}
