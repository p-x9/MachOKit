//
//  FatArch.swift
//  
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public struct FatArch: LayoutWrapper, Sendable {
    public var layout: fat_arch

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
}
