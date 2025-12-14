//
//  CodeSignGenericBlob.swift
//
//
//  Created by p-x9 on 2024/03/04.
//  
//

import Foundation
import MachOKitC

public struct CodeSignGenericBlob: LayoutWrapper, Sendable {
    public typealias Layout = CS_GenericBlob

    public var layout: Layout
}

extension CodeSignGenericBlob {
    public var isSwapped: Bool {
        layout.isSwapped
    }

    public var magic: CodeSignMagic! {
        .init(rawValue: isSwapped ? layout.magic.byteSwapped : layout.magic)
    }

    public var length: Int {
        numericCast(isSwapped ? layout.length.byteSwapped : layout.length)
    }
}

extension CodeSignGenericBlob {
    static func load(
        from baseAddress: UnsafeRawPointer,
        offset: Int,
        isSwapped: Bool
    ) -> CodeSignGenericBlob? {
        let ptr = baseAddress.advanced(by: offset)
        var _magic = ptr
            .assumingMemoryBound(to: UInt32.self)
            .pointee
        if isSwapped { _magic = _magic.byteSwapped }
        guard CodeSignMagic(rawValue: _magic) != nil else {
            return nil
        }
        let layout = ptr
            .assumingMemoryBound(to: CS_GenericBlob.self)
            .pointee
        return .init(
            layout: isSwapped ? layout.swapped : layout
        )
    }
}

extension CS_GenericBlob {
    var isSwapped: Bool {
        magic < 0xfade0000
    }

    var swapped: CS_GenericBlob {
        var swapped = CS_GenericBlob()
        swapped.magic = magic.byteSwapped
        swapped.length = length.byteSwapped
        return swapped
    }
}
