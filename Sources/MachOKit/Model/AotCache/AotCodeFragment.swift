//
//  AotCodeFragment.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/15
//  
//

import MachOKitC

public struct AotCodeFragment: LayoutWrapper {
    public typealias Layout = aot_code_fragment_metadata

    public var layout: Layout
}

extension AotCodeFragment {
    public var type: AotCodeFragmentType {
        .init(rawValue: layout.type)!
    }
}

extension AotCodeFragment {
    public func imagePath(
        x86DyldCache cache: DyldCache
    ) -> String? {
        _imagePath(x86DyldCache: cache)
    }

    public func imagePath(
        x86DyldCache cache: FullDyldCache
    ) -> String? {
       _imagePath(x86DyldCache: cache)
    }

    private func _imagePath<Cache: _DyldCacheFileRepresentable>(
        x86DyldCache cache: Cache
    ) -> String? {
        if type == .runtime { return "RuntimeRoutines" }
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(layout.image_path_offset)
        guard let fileOffset = cache.fileOffset(
            of: address
        ) else { return nil }

        return cache.fileHandle.readString(
            offset: fileOffset
        )
    }
}
