//
//  PrebuiltLoaderSet.swift
//
//
//  Created by p-x9 on 2024/07/09
//
//

import Foundation

public struct PrebuiltLoaderSet: LayoutWrapper {
    public typealias Layout = prebuilt_loader_set

    public var layout: Layout
    public var address: Int
}

extension PrebuiltLoaderSet {
    public func loaders(in cache: DyldCache) -> [PrebuiltLoader]? {
        guard let offset = cache.fileOffset(of: numericCast(address)) else {
            return nil
        }
        let offsets: DataSequence<UInt32> = cache.fileHandle.readDataSequence(
            offset: offset + numericCast(layout.loadersArrayOffset),
            numberOfElements: numericCast(layout.loadersArrayCount)
        )
        return offsets.compactMap { _offset -> PrebuiltLoader? in
            guard let offset = cache.fileOffset(
                of: numericCast(address) + numericCast(_offset)
            ) else {
                return nil
            }
            return cache.fileHandle.readData(
                offset: numericCast(offset),
                size: PrebuiltLoader.layoutSize
            ).withUnsafeBytes {
                let loader = $0.load(as: prebuilt_loader.self)
                return PrebuiltLoader(
                    layout: loader,
                    address: address + numericCast(_offset)
                )
            }
        }
    }
}
