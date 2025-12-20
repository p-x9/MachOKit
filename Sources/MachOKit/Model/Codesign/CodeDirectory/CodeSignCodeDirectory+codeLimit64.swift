//
//  CodeSignCodeDirectory+codeLimit64.swift
//
//
//  Created by p-x9 on 2024/03/11.
//
//

import Foundation

extension CodeSignCodeDirectory {
    public func codeLimit64(in signature: MachOFile.CodeSign) -> CodeLimit64? {
        guard isSupportsCodeLimit64 else {
            return nil
        }
        let layout: CS_CodeDirectory_CodeLimit64 = signature.fileSlice.ptr
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .advanced(by: ScatterOffset.layoutSize)
            .advanced(by: TeamIdOffset.layoutSize)
            .assumingMemoryBound(to: CS_CodeDirectory_CodeLimit64.self)
            .pointee
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}

extension CodeSignCodeDirectory {
    public func codeLimit64(in signature: MachOImage.CodeSign) -> CodeLimit64? {
        guard isSupportsCodeLimit64 else {
            return nil
        }
        let layout: CS_CodeDirectory_CodeLimit64? = signature.basePointer
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .advanced(by: ScatterOffset.layoutSize)
            .advanced(by: TeamIdOffset.layoutSize)
            .assumingMemoryBound(to: CS_CodeDirectory_CodeLimit64.self)
            .pointee
        guard let layout else { return nil }
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}
