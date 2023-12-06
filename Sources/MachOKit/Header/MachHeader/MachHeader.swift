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
    public var layout: mach_header

    public var magic: Magic! {
        .init(rawValue: layout.magic)
    }

    public var cpuType: CPUType? {
        cpu.type
    }

    public var cpuSubType: CPUSubType? {
        cpu.subtype
    }

    public var cpu: CPU {
        .init(
            typeRawValue: layout.cputype,
            subtypeRawValue: layout.cpusubtype
        )
    }

    public var fileType: FileType? {
        .init(rawValue: numericCast(layout.filetype))
    }

    public var flags: Flags {
        .init(rawValue: numericCast(layout.flags))
    }
}
