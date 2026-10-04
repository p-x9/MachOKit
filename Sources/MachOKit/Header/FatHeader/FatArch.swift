//
//  FatArch.swift
//  
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public protocol FatArchProtocol: LayoutWrapper, Sendable {
    var cpu: CPU { get }
    var cpuType: CPUType? { get }
    var cpuSubType: CPUSubType? { get }
    /// File offset of the architecture's payload within the fat container.
    var offset: UInt64 { get }
    /// Size of the architecture's payload in bytes.
    var size: UInt64 { get }
    /// Alignment as a power of two.
    var align: UInt32 { get }
}

extension FatArchProtocol {
    public var cpuType: CPUType? { cpu.type }
    public var cpuSubType: CPUSubType? { cpu.subtype }
}

public struct FatArch: FatArchProtocol {
    public var layout: fat_arch

    public var offset: UInt64 { UInt64(layout.offset) }
    public var size: UInt64 { UInt64(layout.size) }
    public var align: UInt32 { layout.align }

    public var cpu: CPU {
        .init(
            typeRawValue: layout.cputype,
            subtypeRawValue: layout.cpusubtype
        )
    }
}

/// An architecture entry preserving the `fat_arch_64` layout.
public struct FatArch64: FatArchProtocol {
    public var layout: fat_arch_64

    public var offset: UInt64 { layout.offset }
    public var size: UInt64 { layout.size }
    public var align: UInt32 { layout.align }

    public var cpu: CPU {
        .init(
            typeRawValue: layout.cputype,
            subtypeRawValue: layout.cpusubtype
        )
    }
}
