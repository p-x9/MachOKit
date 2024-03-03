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
                    let ptr = baseAddress.advanced(by: numericCast($0.offset))
                    var _magic = ptr
                        .assumingMemoryBound(to: UInt32.self)
                        .pointee
                    if isSwapped { _magic = _magic.byteSwapped }
                    guard let magic = CodeSignMagic(rawValue: _magic),
                          magic == .codedirectory else {
                        return nil
                    }
                    return ptr
                        .assumingMemoryBound(to: CS_CodeDirectory.self)
                        .pointee
                }
                .map {
                    isSwapped ? .init(layout: $0.swapped) : .init(layout: $0)
                }
        }
    }
}
