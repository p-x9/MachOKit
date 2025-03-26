//
//  CodeSignCodeDirectory+scatter.swift
//
//
//  Created by p-x9 on 2024/03/11.
//
//

import Foundation

extension CodeSignCodeDirectory {
    public func scatterOffset(in signature: MachOFile.CodeSign) -> ScatterOffset? {
        guard isSupportsScatter else {
            return nil
        }
        let layout: CS_CodeDirectory_Scatter = signature.fileSice.ptr
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .assumingMemoryBound(to: CS_CodeDirectory_Scatter.self)
            .pointee

        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}

extension CodeSignCodeDirectory {
    public func scatterOffset(in signature: MachOImage.CodeSign) -> ScatterOffset? {
        guard isSupportsScatter else {
            return nil
        }
        let layout: CS_CodeDirectory_Scatter? = signature.basePointer
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .assumingMemoryBound(to: CS_CodeDirectory_Scatter.self)
            .pointee
        guard let layout else { return nil }

        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}
