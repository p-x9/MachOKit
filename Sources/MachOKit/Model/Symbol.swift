//
//  Symbol.swift
//
//
//  Created by p-x9 on 2023/12/14.
//  
//

import Foundation

public struct Symbol {
    public let name: String

    /// Offset from start of mach header (`MachO`)
    /// File offset from mach header (`MachOFile`)
    public let offset: Int

    /// Nlist or Nlist64
    public let nlist: any NlistProtocol
}
