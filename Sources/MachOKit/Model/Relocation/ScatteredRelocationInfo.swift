//
//  ScatteredRelocationInfo.swift
//
//
//  Created by p-x9 on 2024/01/10.
//  
//

import Foundation

public struct ScatteredRelocationInfo: LayoutWrapper {
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
        switch cpuType {
        case .x86:
            guard let type = GenericRelocationType(rawValue: layout.r_type) else {
                return nil
            }
            return .x86(type)

        case .x86_64:
            guard let type = X86_64RelocationType(rawValue: layout.r_type) else {
                return nil
            }
            return .x86_64(type)

        case .arm:
            guard let type = ARMRelocationType(rawValue: layout.r_type) else {
                return nil
            }
            return .arm(type)

        case .arm64:
            guard let type = ARM64RelocationType(rawValue: layout.r_type) else {
                return nil
            }
            return .arm64(type)

        case .powerpc:
            guard let type = PPCRelocationType(rawValue: layout.r_type) else {
                return nil
            }
            return .ppc(type)

        default:
            return nil
        }
    }
}
