//
//  RelocationInfo.swift
//  
//
//  Created by p-x9 on 2024/01/10.
//  
//

import Foundation

public struct RelocationInfo: LayoutWrapper {
    public typealias Layout = relocation_info

    public var layout: Layout
}

extension RelocationInfo {
    public var isRelocatedPCRelative: Bool {
        layout.r_pcrel != 0
    }

    public var length: RelocationLength? {
        .init(rawValue: layout.r_length)
    }

    public var isExternal: Bool {
        layout.r_extern != 0
    }

    public var isScattered: Bool {
        UInt32(bitPattern: layout.r_address) & R_SCATTERED != 0
    }

    public var symbolIndex: Int? {
        isExternal ? numericCast(layout.r_symbolnum) : nil
    }

    public var sectionOrdinal: Int? {
        isExternal ? nil : numericCast(layout.r_symbolnum)
    }

    public func type(for cpuType: CPUType) -> RelocationType? {
        .init(rawValue: layout.r_type, for: cpuType)
    }
}
