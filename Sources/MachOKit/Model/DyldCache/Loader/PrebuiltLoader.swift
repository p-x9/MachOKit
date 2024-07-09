//
//  PrebuiltLoader.swift
//  
//
//  Created by p-x9 on 2024/07/09
//  
//

import Foundation

public struct PrebuiltLoader: LayoutWrapper {
    public typealias Layout = prebuilt_loader

    public var layout: Layout
    public var address: Int
}

extension PrebuiltLoader {
    public func path(in cache: DyldCache) -> String? {
        guard let offset = cache.fileOffset(
            of: numericCast(address) + numericCast(layout.pathOffset)
        ) else { return nil }
        return cache.fileHandle.readString(offset: offset)
    }
}
