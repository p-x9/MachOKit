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
    /// Offset from start of mach header (`MachO`)
    /// Offset from start of file (`MachOFile`)
    public var offset: Int
}
