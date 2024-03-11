//
//  CodeSignCodeDirectory+teamID.swift
//
//
//  Created by p-x9 on 2024/03/11.
//
//

import Foundation

extension CodeSignCodeDirectory {
    public func teamIdOffset(in signature: MachOFile.CodeSign) -> TeamIdOffset? {
        guard isSupportsScatter else {
            return nil
        }
        let layout: CS_CodeDirectory_TeamID? = signature.data.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                return nil
            }
            return baseAddress
                .advanced(by: offset)
                .advanced(by: layoutSize)
                .advanced(by: ScatterOffset.layoutSize)
                .assumingMemoryBound(to: CS_CodeDirectory_TeamID.self)
                .pointee
        }
        guard let layout else { return nil }
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }

    public func teamId(in signature: MachOFile.CodeSign) -> String? {
        guard let teamIdOffset = teamIdOffset(in: signature),
              teamIdOffset.teamOffset != 0 else {
            return nil
        }
        return signature.data.withUnsafeBytes {
            let baseAddress = $0.baseAddress!
            let ptr = baseAddress
                .advanced(by: offset)
                .advanced(by: Int(teamIdOffset.teamOffset))
                .assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
    }
}

extension CodeSignCodeDirectory {
    public func teamIdOffset(in signature: MachOImage.CodeSign) -> TeamIdOffset? {
        guard isSupportsScatter else {
            return nil
        }
        let layout: CS_CodeDirectory_TeamID? = signature.basePointer
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .advanced(by: ScatterOffset.layoutSize)
            .assumingMemoryBound(to: CS_CodeDirectory_TeamID.self)
            .pointee
        guard let layout else { return nil }
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }

    public func teamId(in signature: MachOImage.CodeSign) -> String? {
        guard let teamIdOffset = teamIdOffset(in: signature),
              teamIdOffset.teamOffset != 0 else {
            return nil
        }
        let ptr = signature.basePointer
            .advanced(by: offset)
            .advanced(by: Int(teamIdOffset.teamOffset))
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}
