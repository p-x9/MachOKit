//
//  FatHeader.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public struct FatHeader: LayoutWrapper, Sendable {
    public var layout: fat_header

    public var magic: Magic! {
        .init(rawValue: layout.magic)
    }
}

extension FatHeader {
    public func arches(data: Data, isSwapped: Bool) -> [any FatArchProtocol] {
        data.withUnsafeBytes { bytes in
            let stride = magic.is64BitFat
                ? MemoryLayout<fat_arch_64>.stride
                : MemoryLayout<fat_arch>.stride
            let count = min(Int(layout.nfat_arch), bytes.count / stride)
            return (0..<count).map { index -> any FatArchProtocol in
                if magic.is64BitFat {
                    var arch = bytes.loadUnaligned(
                        fromByteOffset: index * stride,
                        as: fat_arch_64.self
                    )
                    if isSwapped {
                        swap_fat_arch_64(&arch, 1, NXHostByteOrder())
                    }
                    return FatArch64(layout: arch)
                } else {
                    var arch = bytes.loadUnaligned(
                        fromByteOffset: index * stride,
                        as: fat_arch.self
                    )
                    if isSwapped {
                        swap_fat_arch(&arch, 1, NXHostByteOrder())
                    }
                    return FatArch(layout: arch)
                }
            }
        }
    }
}
