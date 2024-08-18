//
//  DyldCacheMappingAndSlideInfo.swift
//
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

public struct DyldCacheMappingAndSlideInfo: LayoutWrapper {
    public typealias Layout = dyld_cache_mapping_and_slide_info

    public var layout: Layout
}

extension DyldCacheMappingAndSlideInfo {
    /// Flags of mapping
    public var flags: DyldCacheMappingFlags {
        .init(rawValue: layout.flags)
    }

    /// Max vm protection of this mapping
    public var maxProtection: VMProtection {
        .init(rawValue: VMProtection.RawValue(bitPattern: layout.maxProt))
    }

    /// Initial vm protection of this mapping
    public var initialProtection: VMProtection {
        .init(rawValue: VMProtection.RawValue(bitPattern: layout.maxProt))
    }
}

extension DyldCacheMappingAndSlideInfo {
    public func slideInfoVersion(
        in cache: DyldCache
    ) -> DyldCacheSlideInfo.Version? {
        guard layout.slideInfoFileOffset > 0 else { return nil }
        let _version: UInt32 = cache.fileHandle.read(
            offset: layout.slideInfoFileOffset
        )
        return .init(rawValue: Int(_version))
    }

    public func slideInfo(in cache: DyldCache) -> DyldCacheSlideInfo? {
        guard let version = slideInfoVersion(in: cache) else {
            return nil
        }

        // Note:
        //　`slideInfoFileSize` is the layout size of `dyld_cache_slide_infoX` plus the size of arrays such as page_starts and page_extras.

        let offset = layout.slideInfoFileOffset
        switch version {
        case .none:
            return nil
        case .v1:
            let layout: DyldCacheSlideInfo1.Layout = cache.fileHandle.read(
                offset: offset
            )
            return .v1(.init(layout: layout, offset: numericCast(offset)))
        case .v2:
            let layout: DyldCacheSlideInfo2.Layout = cache.fileHandle.read(
                offset: offset
            )
            return .v2(.init(layout: layout, offset: numericCast(offset)))
        case .v3:
            let layout: DyldCacheSlideInfo3.Layout = cache.fileHandle.read(
                offset: offset
            )
            return .v3(.init(layout: layout, offset: numericCast(offset)))
        case .v4:
            let layout: DyldCacheSlideInfo4.Layout = cache.fileHandle.read(
                offset: offset
            )
            return .v4(.init(layout: layout, offset: numericCast(offset)))
        case .v5:
            let layout: DyldCacheSlideInfo5.Layout = cache.fileHandle.read(
                offset: offset
            )
            return .v5(.init(layout: layout, offset: numericCast(offset)))
        }
    }
}
