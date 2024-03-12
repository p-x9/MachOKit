//
//  CodeSignSuperBlob.swift
//
//
//  Created by p-x9 on 2024/03/03.
//  
//

import Foundation
import MachOKitC

public struct CodeSignSuperBlob: LayoutWrapper {
    public typealias Layout = CS_SuperBlob

    public var layout: Layout
    public let offset: Int // offset from start of linkedit_data
}

extension CodeSignSuperBlob {
    public var magic: CodeSignMagic {
        .init(rawValue: layout.magic)!
    }

    public var count: Int {
        numericCast(layout.count)
    }
}

extension CodeSignSuperBlob {
    /// Get indices of this SuperBlob
    /// - Parameter signature: ``MachOFile.CodeSign`` to which this SuperBlob belongs.
    /// - Returns: indices of this superBlob
    public func blobIndices(
        in signature: MachOFile.CodeSign
    ) -> AnySequence<CodeSignBlobIndex> {
        let offset = offset + layoutSize

        return AnySequence(
            DataSequence<CS_BlobIndex>(
                data: signature.data.advanced(by: offset),
                numberOfElements: count
            ).lazy.map {
                .init(layout: signature.isSwapped ? $0.swapped : $0)
            }
        )
    }
    
    /// Get indices of this SuperBlob
    /// - Parameter signature: ``MachOImage.CodeSign`` to which this SuperBlob belongs.
    /// - Returns: indices of this superBlob
    public func blobIndices(
        in signature: MachOImage.CodeSign
    ) -> AnySequence<CodeSignBlobIndex> {
        let offset = offset + layoutSize

        return AnySequence(
            MemorySequence<CS_BlobIndex>(
                basePointer: signature.basePointer
                    .advanced(by: offset)
                    .assumingMemoryBound(to: CS_BlobIndex.self),
                numberOfElements: count
            ).lazy.map {
                .init(layout: signature.isSwapped ? $0.swapped : $0)
            }
        )
    }
}

extension CS_SuperBlob {
    var isSwapped: Bool {
        magic < 0xfade0000
    }

    var swapped: CS_SuperBlob {
        var swapped = CS_SuperBlob()
        swapped.magic = magic.byteSwapped
        swapped.length = length.byteSwapped
        swapped.count = count.byteSwapped
        return swapped
    }
}
