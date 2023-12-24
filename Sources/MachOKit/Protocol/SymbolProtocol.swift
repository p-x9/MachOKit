//
//  Symbol.swift
//
//
//  Created by p-x9 on 2023/12/14.
//  
//

import Foundation

public protocol SymbolProtocol {
    var name: String { get }

    /// Offset from start of mach header (`MachO`)
    /// File offset from mach header (`MachOFile`)
    var offset: Int { get }

    /// Nlist or Nlist64
    var nlist: any NlistProtocol { get }
}
