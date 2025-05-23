//
//  CodeSignCodeDirectory.swift
//
//
//  Created by p-x9 on 2024/03/03.
//
//

import Foundation
import MachOKitC

#if canImport(CommonCrypto)
import CommonCrypto
#else
#if compiler(>=6.0)
private import Crypto
#elseif compiler(>=5.10) && hasFeature(AccessLevelOnImport)
private import Crypto
#else
@_implementationOnly import Crypto
#endif
#endif /* canImport(CommonCrypto) */

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

}
extension CodeSignCodeDirectory {
    public func identifier(in signature: MachOFile.CodeSign) -> String {
        String(
            cString: signature.fileSice.ptr
                .advanced(by: offset)
                .advanced(by: numericCast(layout.identOffset))
                .assumingMemoryBound(to: CChar.self)
        )
    }

    public func identifier(in signature: MachOImage.CodeSign) -> String {
        String(
            cString: signature.basePointer
                .advanced(by: offset)
                .advanced(by: numericCast(layout.identOffset))
                .assumingMemoryBound(to: CChar.self)
        )
    }
}

extension CodeSignCodeDirectory {
    public func hash(
        in signature: MachOFile.CodeSign
    ) -> Data? {
        let data = try! signature.fileSice.readData(
            offset: offset,
            length: numericCast(layout.length)
        )
        return _hash(for: data)
    }

    public func hash(
        in signature: MachOImage.CodeSign
    ) -> Data? {
        let data = Data(
            bytes: signature.basePointer.advanced(by: offset),
            count: numericCast(layout.length)
        )
        return _hash(for: data)
    }
}

extension CodeSignCodeDirectory {
    private func _hash(for data: Data) -> Data? {
#if canImport(CommonCrypto)
        let length: CC_LONG = numericCast(data.count)

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
#else
        switch hashType {
        case .sha1:
            return Data(Insecure.SHA1.hash(data: data))
        case .sha256, .sha256_truncated:
            return Data(SHA256.hash(data: data))
        case .sha384:
            return Data(SHA384.hash(data: data))
        case .none:
            return nil
        }
#endif
    }
}

extension CodeSignCodeDirectory {
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
        return try! signature.fileSice.readData(
            offset: offset,
            length: size
        )
    }

    public func hash(
        forSlot index: Int,
        in signature: MachOImage.CodeSign
    ) -> Data? {
        guard -Int(layout.nSpecialSlots) <= index,
               index < Int(layout.nCodeSlots) else {
            return nil
        }
        let size: Int = numericCast(layout.hashSize)
        let offset = offset + numericCast(layout.hashOffset) + index * size
        return Data(
            bytes: signature.basePointer.advanced(by: offset),
            count: size
        )
    }

}

extension CodeSignCodeDirectory {
    public func hash(
        for specialSlot: CodeSignSpecialSlotType,
        in signature: MachOFile.CodeSign
    ) -> Data? {
        hash(forSlot: -specialSlot.rawValue, in: signature)
    }

    public func hash(
        for specialSlot: CodeSignSpecialSlotType,
        in signature: MachOImage.CodeSign
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

// TODO: Version 0x20600 (Linkage)
