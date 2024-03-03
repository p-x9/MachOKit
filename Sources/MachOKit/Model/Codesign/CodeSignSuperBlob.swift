//
//  CodeSignSuperBlob.swift
//
//
//  Created by p-x9 on 2024/03/03.
//  
//

import Foundation
import MachOKitC

public struct CodeSignSuperBlob: LayoutWrapper {
    public typealias Layout = CS_SuperBlob

    public var layout: Layout
}

extension CodeSignSuperBlob {
    public var isSwapped: Bool {
        layout.isSwapped
    }

    public var magic: CodeSignMagic {
        .init(rawValue: isSwapped ? layout.magic.byteSwapped : layout.magic)!
    }

    public var count: Int {
        numericCast(isSwapped ? layout.count.byteSwapped : layout.count)
    }
}

extension CS_SuperBlob {
    var isSwapped: Bool {
        magic < 0xfade0000
    }

    var swapped: CS_SuperBlob {
        var swapped = CS_SuperBlob()
        swapped.magic = magic.byteSwapped
        swapped.length = length.byteSwapped
        swapped.count = count.byteSwapped
        return swapped
    }
}
