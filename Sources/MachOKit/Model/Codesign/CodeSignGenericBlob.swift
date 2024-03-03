//
//  CodeSignGenericBlob.swift
//
//
//  Created by p-x9 on 2024/03/04.
//  
//

import Foundation
import MachOKitC

public struct CodeSignGenericBlob: LayoutWrapper {
    public typealias Layout = CS_GenericBlob

    public var layout: Layout
}

extension CodeSignGenericBlob {
    public var isSwapped: Bool {
        layout.isSwapped
    }

    public var magic: CodeSignMagic {
        .init(rawValue: isSwapped ? layout.magic.byteSwapped : layout.magic)!
    }

    public var length: Int {
        numericCast(isSwapped ? layout.length.byteSwapped : layout.length)
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
