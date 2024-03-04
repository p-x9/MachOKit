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
            let layout = basePtr.assumingMemoryBound(to: CS_SuperBlob.self).pointee
            return isSwapped ? .init(layout: layout.swapped) : .init(layout: layout)
        }
    }

    public var blobIndices: AnySequence<CodeSignBlobIndex> {
        guard let superBlob else { return AnySequence([]) }
        let offset = superBlob.layoutSize

        return AnySequence(
            DataSequence<CS_BlobIndex>(
                data: data.advanced(by: offset),
                numberOfElements: superBlob.count
            ).lazy.map {
                .init(layout: isSwapped ? $0.swapped : $0)
            }
        )
    }

    public var codeDirectories: [CodeSignCodeDirectory] {
        data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return []
            }
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

    public var embeddedEntitlements: Dictionary<String, Any>? {
        data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }
            return blobIndices
                .lazy
                .compactMap { index in
                    let ptr = baseAddress.advanced(by: numericCast(index.offset))
                    let _blob = ptr.assumingMemoryBound(to: CS_GenericBlob.self).pointee
                    let blob = CodeSignGenericBlob(
                        layout: isSwapped ? _blob.swapped : _blob
                    )
                    guard blob.magic == .embedded_entitlements else {
                        return nil
                    }
                    let entitlementsData = Data(
                        bytes: ptr.advanced(by: blob.layoutSize), // 8 = magic & length field
                        count: numericCast(blob.length) - blob.layoutSize
                    )
                    guard let entitlements = try? PropertyListSerialization.propertyList(
                        from: entitlementsData,
                        format: nil
                    ) else {
                        return nil
                    }
                    return entitlements as? Dictionary<String, Any>
                }
                .first
        }
    }

    public var embeddedDEREntitlementsData: Data? {
        data.withUnsafeBytes { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }
            return blobIndices
                .lazy
                .compactMap { index in
                    let ptr = baseAddress.advanced(by: numericCast(index.offset))
                    let _blob = ptr.assumingMemoryBound(to: CS_GenericBlob.self).pointee
                    let blob = CodeSignGenericBlob(
                        layout: isSwapped ? _blob.swapped : _blob
                    )
                    guard blob.magic == .embedded_der_entitlements else {
                        return nil
                    }
                    return Data(
                        bytes: ptr.advanced(by: blob.layoutSize), // 8 = magic & length field
                        count: numericCast(blob.length) - blob.layoutSize
                    )
                }
                .first
        }
    }
}
