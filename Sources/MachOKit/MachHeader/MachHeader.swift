//
//  MachHeader.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation
import Darwin

public struct MachHeader: LayoutWrapper {
    public let layout: mach_header

    public var cpuType: CPUType? {
        .init(rawValue: layout.cputype)
    }

    public var cpu: CPU? {
        if let cpuType { CPU(type: cpuType, subtype: layout.cpusubtype) }
        else { nil }
    }

    public var fileType: FileType? {
        .init(rawValue: numericCast(layout.filetype))
    }

    public var flags: Flags {
        .init(rawValue: numericCast(layout.flags))
    }
}

