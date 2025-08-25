//
//  ScatteredRelocationInfo.swift
//
//
//  Created by p-x9 on 2024/01/10.
//  
//

import Foundation

public struct ScatteredRelocationInfo: LayoutWrapper, Sendable {
    public typealias Layout = scattered_relocation_info

    public var layout: Layout
}

extension ScatteredRelocationInfo {
    public var isRelocatedPCRelative: Bool {
        layout.r_pcrel != 0
    }

    public var length: RelocationLength? {
        .init(rawValue: layout.r_length)
    }

    public var isScattered: Bool {
        layout.r_scattered != 0
    }

    public func type(for cpuType: CPUType) -> RelocationType? {
        .init(rawValue: layout.r_type, for: cpuType)
    }
}
