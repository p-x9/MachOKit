//
//  CodeSignCodeDirectory.swift
//
//
//  Created by p-x9 on 2024/03/03.
//  
//

import Foundation
import MachOKitC
import CommonCrypto

public struct CodeSignCodeDirectory: LayoutWrapper {
    public typealias Layout = CS_CodeDirectory

    public var layout: Layout
    public let offset: Int // offset from start of linkedit_data
}

extension CodeSignCodeDirectory {
    public var magic: CodeSignMagic! {
        .init(rawValue: layout.magic)
    }

    public var hashType: CodeSignHashType! {
        .init(rawValue: UInt32(layout.hashType))
    }

    public func identifier(in signature: MachOFile.CodeSign) -> String {
        signature.data.withUnsafeBytes {
            bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return ""
            }
            return String(
                cString: baseAddress
                    .advanced(by: offset)
                    .advanced(by: numericCast(layout.identOffset))
                    .assumingMemoryBound(to: CChar.self)
            )
        }
    }

    public func hash(
        in signature: MachOFile.CodeSign
    ) -> Data? {
        let data = signature.data[offset ..< offset + numericCast(layout.length)]
        let length: CC_LONG = numericCast(layout.length)

        return data.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                return nil
            }
            switch hashType {
            case .sha1:
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
                CC_SHA1(baseAddress, length, &digest)
                return Data(digest)
            case .sha256, .sha256_truncated:
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
                CC_SHA256(baseAddress, length, &digest)
                return Data(digest)
            case .sha384:
                var digest = [UInt8](repeating: 0, count: Int(CC_SHA384_DIGEST_LENGTH))
                CC_SHA384(baseAddress, length, &digest)
                return Data(digest)
            case .none:
                return nil
            }
        }
    }

    public func hash(
        forSlot index: Int,
        in signature: MachOFile.CodeSign
    ) -> Data? {
        guard -Int(layout.nSpecialSlots) <= index,
               index < Int(layout.nCodeSlots) else {
            return nil
        }
        let size: Int = numericCast(layout.hashSize)
        let offset = offset + numericCast(layout.hashOffset) + index * size
        return signature.data[offset ..< offset + size]
    }

    public func hash(
        for specialSlot: CodeSignSpecialSlotType,
        in signature: MachOFile.CodeSign
    ) -> Data? {
        hash(forSlot: -specialSlot.rawValue, in: signature)
    }
}

extension CodeSignCodeDirectory {
    public var isSupportsScatter: Bool {
        layout.version >= CS_SUPPORTSSCATTER
    }

    public var isSupportsTeamID: Bool {
        layout.version >= CS_SUPPORTSTEAMID
    }

    public var isSupportsCodeLimit64: Bool {
        layout.version >= CS_SUPPORTSCODELIMIT64
    }

    public var isSupportsExecSegment: Bool {
        layout.version >= CS_SUPPORTSEXECSEG
    }

    public var isSupportsRuntime: Bool {
        layout.version >= CS_SUPPORTSRUNTIME
    }

    public var isSupportsLinkage: Bool {
        layout.version >= CS_SUPPORTSLINKAGE
    }
}

extension CodeSignCodeDirectory {
    public struct ScatterOffset: LayoutWrapper {
        public typealias Layout = CS_CodeDirectory_Scatter

        public var layout: Layout
    }

    public struct TeamIdOffset: LayoutWrapper {
        public typealias Layout = CS_CodeDirectory_TeamID

        public var layout: Layout
    }

    public struct CodeLimit64: LayoutWrapper {
        public typealias Layout = CS_CodeDirectory_CodeLimit64

        public var layout: Layout
    }

    public struct ExecutableSegment: LayoutWrapper {
        public typealias Layout = CS_CodeDirectory_ExecSeg

        public var layout: Layout

        public var flags: CodeSignExecSegmentFlags {
            .init(rawValue: layout.execSegFlags)
        }
    }

    public struct Runtime: LayoutWrapper {
        public typealias Layout = CS_CodeDirectory_Runtime

        public var layout: Layout

        public var runtime: Version {
            .init(layout.runtime)
        }
    }
}

extension CodeSignCodeDirectory {
    public func scatterOffset(in signature: MachOFile.CodeSign) -> ScatterOffset? {
        guard isSupportsScatter else {
            return nil
        }
        let layout: CS_CodeDirectory_Scatter? = signature.data.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                return nil
            }
            return baseAddress
                .advanced(by: offset)
                .advanced(by: layoutSize)
                .assumingMemoryBound(to: CS_CodeDirectory_Scatter.self)
                .pointee
        }
        guard let layout else { return nil }

        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}

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
    public func codeLimit64(in signature: MachOFile.CodeSign) -> CodeLimit64? {
        guard isSupportsCodeLimit64 else {
            return nil
        }
        let layout: CS_CodeDirectory_CodeLimit64? = signature.data.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                return nil
            }
            return baseAddress
                .advanced(by: offset)
                .advanced(by: layoutSize)
                .advanced(by: ScatterOffset.layoutSize)
                .advanced(by: TeamIdOffset.layoutSize)
                .assumingMemoryBound(to: CS_CodeDirectory_CodeLimit64.self)
                .pointee
        }
        guard let layout else { return nil }
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}

extension CodeSignCodeDirectory {
    public func executableSegment(in signature: MachOFile.CodeSign) -> ExecutableSegment? {
        guard isSupportsExecSegment else {
            return nil
        }
        let layout: CS_CodeDirectory_ExecSeg? = signature.data.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                return nil
            }
            return baseAddress
                .advanced(by: offset)
                .advanced(by: layoutSize)
                .advanced(by: ScatterOffset.layoutSize)
                .advanced(by: TeamIdOffset.layoutSize)
                .advanced(by: CodeLimit64.layoutSize)
                .assumingMemoryBound(to: CS_CodeDirectory_ExecSeg.self)
                .pointee
        }
        guard let layout else { return nil }
        return .init(
            layout: signature.isSwapped ? layout.swapped : layout
        )
    }
}

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

    public func preEncryptHash(
        forSlot index: Int,
        in signature: MachOFile.CodeSign
    ) -> Data? {
        guard  0 <= index,
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
}

extension CS_CodeDirectory {
    var isSwapped: Bool {
        magic < 0xfade0000
    }
    
    var swapped: CS_CodeDirectory {
        .init(
            magic: magic.byteSwapped,
            length: length.byteSwapped,
            version: version.byteSwapped,
            flags: flags.byteSwapped,
            hashOffset: hashOffset.byteSwapped,
            identOffset: identOffset.byteSwapped,
            nSpecialSlots: nSpecialSlots.byteSwapped,
            nCodeSlots: nCodeSlots.byteSwapped,
            codeLimit: codeLimit.byteSwapped,
            hashSize: hashSize.byteSwapped,
            hashType: hashType.byteSwapped,
            platform: platform.byteSwapped,
            pageSize: pageSize.byteSwapped,
            spare2: spare2.byteSwapped, 
            end_earliest: end_earliest
        )
    }
}

extension CS_CodeDirectory_Scatter {
    var swapped: CS_CodeDirectory_Scatter {
        .init(
            scatterOffset: scatterOffset.byteSwapped,
            end_withScatter: end_withScatter
        )
    }
}

extension CS_CodeDirectory_TeamID {
    var swapped: CS_CodeDirectory_TeamID {
        .init(
            teamOffset: teamOffset.byteSwapped,
            end_withTeam: end_withTeam
        )
    }
}

extension CS_CodeDirectory_CodeLimit64 {
    var swapped: CS_CodeDirectory_CodeLimit64 {
        .init(
            spare3: spare3.byteSwapped,
            codeLimit64: codeLimit64.byteSwapped
        )
    }
}

extension CS_CodeDirectory_ExecSeg {
    var swapped: CS_CodeDirectory_ExecSeg {
        .init(
            execSegBase: execSegBase.byteSwapped,
            execSegLimit: execSegLimit.byteSwapped,
            execSegFlags: execSegFlags.byteSwapped,
            end_withExecSeg: end_withExecSeg
        )
    }
}

extension CS_CodeDirectory_Runtime {
    var swapped: CS_CodeDirectory_Runtime {
        .init(
            runtime: runtime.byteSwapped,
            preEncryptOffset: preEncryptOffset.byteSwapped,
            end_withPreEncryptOffset: end_withPreEncryptOffset
        )
    }
}

// TODO: scatter vector
// So far I have not been able to find a binary where the scatter exists.
// https://github.com/apple-oss-distributions/libsecurity_codesigning/blob/f2cc42c7b45d1c0d69f1551bd5b84adccf5fa821/lib/codedirectory.h#L223C2-L228C4
