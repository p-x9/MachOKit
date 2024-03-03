//
//  CodeSignBlobIndex.swift
//
//
//  Created by p-x9 on 2024/03/03.
//
//

import Foundation
import MachOKitC

public struct CodeSignBlobIndex: LayoutWrapper {
    public typealias Layout = CS_BlobIndex

    public var layout: Layout
}

extension CodeSignBlobIndex {
    public var type: CodeSignSlot! {
        .init(rawValue: layout.type)
    }
}

extension CS_BlobIndex {
    var swapped: CS_BlobIndex {
        .init(
            type: type.byteSwapped,
            offset: offset.byteSwapped
        )
    }
}
