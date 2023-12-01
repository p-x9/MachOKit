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

    public var magic: Magic! {
        .init(rawValue: layout.magic)
    }

    public var cpuType: CPUType? {
        .init(rawValue: layout.cputype)
    }

    public var cpu: CPU? {
        if let cpuType {
            let subtypeRaw = (cpu_subtype_t(layout.cpusubtype) & cpu_subtype_t(~CPU_SUBTYPE_MASK))
            return CPU(
                type: cpuType,
                subtype: subtypeRaw
            )
        } else {
            return nil
        }
    }

    public var fileType: FileType? {
        .init(rawValue: numericCast(layout.filetype))
    }

    public var flags: Flags {
        .init(rawValue: numericCast(layout.flags))
    }
}

