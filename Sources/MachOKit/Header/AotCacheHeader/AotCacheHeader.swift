//
//  AotCacheHeader.swift
//  MachOKit
//
//  Created by p-x9 on 2025/01/29
//  
//

import Foundation
import MachOKitC

public struct AotCacheHeader: LayoutWrapper {
    public typealias Layout = aot_cache_header

    public var layout: Layout
}

extension AotCacheHeader {
    public var magic: String {
        .init(tuple: layout.magic)
    }

    public var uuid: UUID {
        .init(uuid: layout.uuid)
    }

    public var x86UUID: UUID {
        .init(uuid: layout.x86_uuid)
    }

    public var headerSize: Int {
        numericCast(layout.header_size)
    }
}
