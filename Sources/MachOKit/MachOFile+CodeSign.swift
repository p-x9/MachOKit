//
//  MachOFile+CodeSign.swift
//
//
//  Created by p-x9 on 2024/03/03.
//
//

import Foundation
import MachOKitC

extension MachOFile {
    public struct CodeSign {
        let data: Data
        let isSwapped: Bool // bigEndian => false
    }
}

extension MachOFile.CodeSign {
    public var superBlob: CodeSignSuperBlob? {
        data.withUnsafeBytes {
            guard let basePtr = $0.baseAddress else { return nil }
            var layout = basePtr.assumingMemoryBound(to: CS_SuperBlob.self).pointee
            if isSwapped { layout = layout.swapped }
            return .init(
                layout: layout,
                offset: 0
            )
        }
    }

    public var codeDirectories: [CodeSignCodeDirectory] {
        data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress,
                  let superBlob else {
                return []
            }
            let blobIndices = superBlob.blobIndices(in: self)
            return blobIndices
                .compactMap {
                    let offset: Int = numericCast($0.offset)
                    let ptr = baseAddress.advanced(by: offset)
                    let _blob = ptr.assumingMemoryBound(to: CS_GenericBlob.self).pointee
                    let blob = CodeSignGenericBlob(
                        layout: isSwapped ? _blob.swapped : _blob
                    )
                    guard blob.magic == .codedirectory else {
                        return nil
                    }
                    return (
                        ptr.assumingMemoryBound(to: CS_CodeDirectory.self).pointee,
                        offset
                    )
                }
                .map {
                    isSwapped ? .init(layout: $0.swapped, offset: $1)
                    : .init(layout: $0, offset: $1)
                }
        }
    }

    public var embeddedEntitlementsData: Data? {
        guard let superBlob else {
            return nil
        }
        let blobIndices = superBlob.blobIndices(in: self)
        guard let index = blobIndices.first(
            where: { $0.type == .entitlements }
        ) else {
            return nil
        }
        return data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }
            let ptr = baseAddress.advanced(by: numericCast(index.offset))
            let _blob = ptr.assumingMemoryBound(to: CS_GenericBlob.self).pointee
            let blob = CodeSignGenericBlob(
                layout: isSwapped ? _blob.swapped : _blob
            )

            return Data(
                bytes: ptr.advanced(by: blob.layoutSize), // 8 = magic & length field
                count: numericCast(blob.length) - blob.layoutSize
            )
        }
    }

    public var embeddedEntitlements: [String: Any]? {
        guard let embeddedEntitlementsData else {
            return nil
        }
        guard let entitlements = try? PropertyListSerialization.propertyList(
            from: embeddedEntitlementsData,
            format: nil
        ) else {
            return nil
        }
        return entitlements as? [String: Any]
    }

    public var embeddedDEREntitlementsData: Data? {
        guard let superBlob else {
            return nil
        }
        let blobIndices = superBlob.blobIndices(in: self)
        guard let index = blobIndices.first(
            where: { $0.type == .der_entitlements }
        ) else {
            return nil
        }
        return data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }
            let ptr = baseAddress.advanced(by: numericCast(index.offset))
            let _blob = ptr.assumingMemoryBound(to: CS_GenericBlob.self).pointee
            let blob = CodeSignGenericBlob(
                layout: isSwapped ? _blob.swapped : _blob
            )
            return Data(
                bytes: ptr.advanced(by: blob.layoutSize),
                count: numericCast(blob.length) - blob.layoutSize
            )
        }
    }

    public var signatureData: Data? {
        guard let superBlob else {
            return nil
        }
        let blobIndices = superBlob.blobIndices(in: self)
        guard let index = blobIndices.first(
            where: { $0.type == .signatureslot }
        ) else {
            return nil
        }
        return data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }
            let ptr = baseAddress.advanced(by: numericCast(index.offset))
            let _blob = ptr.assumingMemoryBound(to: CS_GenericBlob.self).pointee
            let blob = CodeSignGenericBlob(
                layout: isSwapped ? _blob.swapped : _blob
            )
            return Data(
                bytes: ptr.advanced(by: blob.layoutSize),
                count: numericCast(blob.length) - blob.layoutSize
            )
        }
    }

    public var requirementsBlob: CodeSignSuperBlob? {
        guard let superBlob else {
            return nil
        }
        let blobIndices = superBlob.blobIndices(in: self)
        guard let index = blobIndices.first(
            where: { $0.type == .requirements }
        ) else {
            return nil
        }
        return data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }
            let offset: Int = numericCast(index.offset)
            let ptr = baseAddress.advanced(by: offset)
            var _blob = ptr
                .assumingMemoryBound(to: CS_SuperBlob.self)
                .pointee
            if isSwapped { _blob = _blob.swapped }

            return .init(
                layout: _blob,
                offset: offset
            )
        }
    }
}

extension MachOFile.CodeSign {
    /// Get blob data as `Data`
    /// - Parameters:
    ///   - superBlob: SuperBlob to which index belongs
    ///   - index: Index of the blob to be gotten
    /// - Returns: Data of blob
    ///
    /// Blob data contains information defined in the `CodeSignGenericBlob` such as magic and length.
    /// Note that when converting from this data to other blob models, byte swapping must be performed appropriately for the `isSwapped` parameter.
    public func blobData(
        in superBlob: CodeSignSuperBlob,
        at index: CodeSignBlobIndex
    ) -> Data? {
        return data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }
            let offset: Int = numericCast(superBlob.offset) + numericCast(index.offset)
            let ptr = baseAddress.advanced(by: offset)
            var _blob = ptr
                .assumingMemoryBound(to: CS_SuperBlob.self)
                .pointee
            if isSwapped { _blob = _blob.swapped }

            return Data(
                bytes: ptr,
                count: numericCast(_blob.length)
            )
        }
    }
}
