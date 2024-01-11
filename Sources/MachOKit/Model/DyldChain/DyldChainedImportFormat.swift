//
//  DyldChainedImportFormat.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

public enum DyldChainedImportFormat: UInt32 {
    /// DYLD_CHAINED_IMPORT
    case general = 1
    /// DYLD_CHAINED_IMPORT_ADDEND
    case addend
    /// DYLD_CHAINED_IMPORT_ADDEND64
    case addend64
}

extension DyldChainedImportFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .general: "DYLD_CHAINED_IMPORT"
        case .addend: "DYLD_CHAINED_IMPORT_ADDEND"
        case .addend64: "DYLD_CHAINED_IMPORT_ADDEND64"
        }
    }
}
