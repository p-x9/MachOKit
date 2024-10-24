//
//  CodeSignCodeDirectory+runtime.swift
//
//
//  Created by p-x9 on 2024/03/11.
//
//

import Foundation

extension CodeSignCodeDirectory {
    public func runtime(in signature: MachOFile.CodeSign) -> Runtime? {
        guard isSupportsRuntime else {
            return nil
        }
        let layout: CS_CodeDirectory_Runtime? = signature.data.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                return nil
            }
            return baseAddress
                .advanced(by: offset)
                .advanced(by: layoutSize)
                .advanced(by: ScatterOffset.layoutSize)
                .advanced(by: TeamIdOffset.layoutSize)
                .advanced(by: CodeLimit64.layoutSize)
                .advanced(by: ExecutableSegment.layoutSize)
                .assumingMemoryBound(to: CS_CodeDirectory_Runtime.self)
                .pointee
        }
        guard let layout else { return nil }
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }

    public func runtime(in signature: MachOImage.CodeSign) -> Runtime? {
        guard isSupportsRuntime else {
            return nil
        }
        let layout: CS_CodeDirectory_Runtime? = signature.basePointer
            .advanced(by: offset)
            .advanced(by: layoutSize)
            .advanced(by: ScatterOffset.layoutSize)
            .advanced(by: TeamIdOffset.layoutSize)
            .advanced(by: CodeLimit64.layoutSize)
            .advanced(by: ExecutableSegment.layoutSize)
            .assumingMemoryBound(to: CS_CodeDirectory_Runtime.self)
            .pointee
        guard let layout else { return nil }
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}

extension CodeSignCodeDirectory {
    public func preEncryptHash(
        forSlot index: Int,
        in signature: MachOFile.CodeSign
    ) -> Data? {
        guard  index >= 0,
               index < Int(layout.nCodeSlots),
               let runtime = runtime(in: signature),
               runtime.preEncryptOffset != 0 else {
            return nil
        }
        let size: Int = numericCast(layout.hashSize)
        let offset = offset
        + numericCast(runtime.preEncryptOffset)
        + index * size
        return signature.data[offset ..< offset + size]
    }

    public func preEncryptHash(
        forSlot index: Int,
        in signature: MachOImage.CodeSign
    ) -> Data? {
        guard  index >= 0,
               index < Int(layout.nCodeSlots),
               let runtime = runtime(in: signature),
               runtime.preEncryptOffset != 0 else {
            return nil
        }
        let size: Int = numericCast(layout.hashSize)
        let offset = offset
        + numericCast(runtime.preEncryptOffset)
        + index * size
        return Data(
            bytes: signature.basePointer.advanced(by: offset),
            count: size
        )
    }
}
