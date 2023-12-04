//
//  FatHeader.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public struct FatHeader: LayoutWrapper {
    public var layout: fat_header

    public var magic: Magic! {
        .init(rawValue: layout.magic)
    }
}

extension FatHeader {
    public func arches(data: Data, isSwapped: Bool) -> [FatArch] {
        if magic.is64BitFat {
            return data.withUnsafeBytes {
                let ptr = $0.bindMemory(to: fat_arch_64.self)

                if isSwapped {
                    swap_fat_arch_64(.init(mutating: ptr.baseAddress), layout.nfat_arch, NXHostByteOrder())
                }

                guard let baseAddress = ptr.baseAddress else { return [] }

                return ptr.indices.map {
                    let layout = UnsafeRawPointer(baseAddress.advanced(by: $0))
                        .bindMemory(to: fat_arch.self, capacity: 1)
                        .pointee
                    return .init(layout: layout)
                }
            }
        } else {
            return data.withUnsafeBytes {
                let ptr = $0.bindMemory(to: fat_arch.self)

                if isSwapped {
                    swap_fat_arch(.init(mutating: ptr.baseAddress), layout.nfat_arch, NXHostByteOrder())
                }

                return ptr
                    .map { .init(layout: $0) }
            }
        }
    }
}
