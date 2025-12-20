//
//  MachOFile+CodeSign.swift
//
//
//  Created by p-x9 on 2024/03/03.
//
//

import CoreFoundation
import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
#else
@_implementationOnly import FileIO
#endif
import MachOKitC

extension MachOFile {
    public struct CodeSign {
        typealias FileSlice = File.FileSlice

        internal let fileSlice: FileSlice
        public let isSwapped: Bool // bigEndian => false
    }
}

extension MachOFile.CodeSign {
    init(fileSlice: FileSlice) {
        self.fileSlice = fileSlice
        self.isSwapped = CFByteOrderGetCurrent() != CFByteOrderBigEndian.rawValue
    }
}

extension MachOFile.CodeSign {
    public var data: Data? {
        try? fileSlice.readData(offset: 0, length: fileSlice.size)
    }
}

extension MachOFile.CodeSign: CodeSignProtocol {
    public var superBlob: CodeSignSuperBlob? {
        var layout = fileSlice.ptr
            .assumingMemoryBound(to: CS_SuperBlob.self)
            .pointee
        if isSwapped { layout = layout.swapped }
        return .init(
            layout: layout,
            offset: 0
        )
    }

    public var codeDirectories: [CodeSignCodeDirectory] {
        guard let superBlob else { return [] }
        let blobIndices = superBlob.blobIndices(in: self)
        return blobIndices
            .compactMap {
                let offset: Int = numericCast($0.offset)
                let ptr = fileSlice.ptr.advanced(by: offset)
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

    public var requirementsBlob: CodeSignSuperBlob? {
        guard let superBlob else { return nil }
        let blobIndices = superBlob.blobIndices(in: self)
        guard let index = blobIndices.first(
            where: { $0.type == .requirements }
        ) else {
            return nil
        }
        let offset: Int = numericCast(index.offset)
        let ptr = fileSlice.ptr.advanced(by: offset)
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

extension MachOFile.CodeSign {
    /// Get blob data as `Data`
    /// - Parameters:
    ///   - superBlob: SuperBlob to which index belongs
    ///   - index: Index of the blob to be gotten
    ///   - includesGenericInfo: A boolean value that indicates whether the data defined in the ``CodeSignGenericBlob``, such as magic and length, are included or not.
    /// - Returns: Data of blob
    ///
    /// Note that when converting from this data to other blob models, byte swapping must be performed appropriately for the ``MachOFile.CodeSign.isSwapped`` parameter.
    public func blobData(
        in superBlob: CodeSignSuperBlob,
        at index: CodeSignBlobIndex,
        includesGenericInfo: Bool = true
    ) -> Data? {
        let offset: Int = numericCast(superBlob.offset) + numericCast(index.offset)
        guard let _blob: CodeSignGenericBlob = .load(
            from: fileSlice.ptr,
            offset: offset,
            isSwapped: isSwapped
        ) else { return nil }

        let data = Data(
            bytes: fileSlice.ptr.advanced(by: offset),
            count: numericCast(_blob.length)
        )
        if includesGenericInfo {
            return data
        } else {
            return data.advanced(by: CodeSignGenericBlob.layoutSize)
        }
    }

    public func blobIndices(
        of superBlob: CodeSignSuperBlob
    ) -> AnyRandomAccessCollection<CodeSignBlobIndex> {
        superBlob.blobIndices(in: self)
    }
}
