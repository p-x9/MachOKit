//
//  CodeSignCodeDirectory+executableSegment.swift
//
//
//  Created by p-x9 on 2024/03/11.
//
//

import Foundation

extension CodeSignCodeDirectory {
    public func executableSegment(in signature: MachOFile.CodeSign) -> ExecutableSegment? {
        guard isSupportsExecSegment else {
            return nil
        }
        let layout: CS_CodeDirectory_ExecSeg = signature.fileSlice.ptr
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .advanced(by: ScatterOffset.layoutSize)
            .advanced(by: TeamIdOffset.layoutSize)
            .advanced(by: CodeLimit64.layoutSize)
            .assumingMemoryBound(to: CS_CodeDirectory_ExecSeg.self)
            .pointee
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}

extension CodeSignCodeDirectory {
    public func executableSegment(in signature: MachOImage.CodeSign) -> ExecutableSegment? {
        guard isSupportsExecSegment else {
            return nil
        }
        let layout: CS_CodeDirectory_ExecSeg? = signature.basePointer
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .advanced(by: ScatterOffset.layoutSize)
            .advanced(by: TeamIdOffset.layoutSize)
            .advanced(by: CodeLimit64.layoutSize)
            .assumingMemoryBound(to: CS_CodeDirectory_ExecSeg.self)
            .pointee
        guard let layout else { return nil }
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}
