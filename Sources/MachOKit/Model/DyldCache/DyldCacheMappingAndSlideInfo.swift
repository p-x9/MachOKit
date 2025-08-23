//
//  DyldCacheMappingAndSlideInfo.swift
//
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
#else
@_implementationOnly import FileIO
#endif

public struct DyldCacheMappingAndSlideInfo: LayoutWrapper, Sendable {
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
        _slideInfoVersion(in: cache)
    }

    public func slideInfo(
        in cache: DyldCache
    ) -> DyldCacheSlideInfo? {
        _slideInfo(in: cache)
    }

    public func slideInfoVersion(
        in cache: FullDyldCache
    ) -> DyldCacheSlideInfo.Version? {
        _slideInfoVersion(in: cache)
    }

    public func slideInfo(
        in cache: FullDyldCache
    ) -> DyldCacheSlideInfo? {
        _slideInfo(in: cache)
    }
}

extension DyldCacheMappingAndSlideInfo {
    internal func _slideInfoVersion<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DyldCacheSlideInfo.Version? {
        guard layout.slideInfoFileOffset > 0 else { return nil }
        let _version: UInt32 = cache.fileHandle.read(
            offset: layout.slideInfoFileOffset
        )
        return .init(rawValue: numericCast(_version))
    }

    internal func _slideInfo<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> DyldCacheSlideInfo? {
        guard let version = _slideInfoVersion(in: cache) else {
            return nil
        }
        return _slideInfo(
            version: version,
            fileHandle: cache.fileHandle
        )
    }
}

extension DyldCacheMappingAndSlideInfo {
    private func _slideInfo<File: FileIOProtocol>(
        version: DyldCacheSlideInfo.Version,
        fileHandle: File
    ) -> DyldCacheSlideInfo? {
        // Note:
        //　`slideInfoFileSize` is the layout size of `dyld_cache_slide_infoX` plus the size of arrays such as page_starts and page_extras.

        let offset = layout.slideInfoFileOffset
        switch version {
        case .none:
            return nil
        case .v1:
            let layout: DyldCacheSlideInfo1.Layout = fileHandle.read(
                offset: offset
            )
            return .v1(.init(layout: layout, offset: numericCast(offset)))
        case .v2:
            let layout: DyldCacheSlideInfo2.Layout = fileHandle.read(
                offset: offset
            )
            return .v2(.init(layout: layout, offset: numericCast(offset)))
        case .v3:
            let layout: DyldCacheSlideInfo3.Layout = fileHandle.read(
                offset: offset
            )
            return .v3(.init(layout: layout, offset: numericCast(offset)))
        case .v4:
            let layout: DyldCacheSlideInfo4.Layout = fileHandle.read(
                offset: offset
            )
            return .v4(.init(layout: layout, offset: numericCast(offset)))
        case .v5:
            let layout: DyldCacheSlideInfo5.Layout = fileHandle.read(
                offset: offset
            )
            return .v5(.init(layout: layout, offset: numericCast(offset)))
        }
    }
}

extension DyldCacheMappingAndSlideInfo {
    // [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/66c652a1f1f6b7b5266b8bbfd51cb0965d67cc44/common/DyldSharedCache.cpp#L305)
    public var mappingName: String? {
        switch maxProtection {
        case _ where maxProtection.contains(.execute):
            if flags.contains(.textStubs) {
                return  "__TEXT_STUBS"
            } else {
                return "__TEXT"
            }
        case _ where maxProtection.contains(.write):
            if flags.contains(.authData) {
                if flags.contains(.dirtyData) {
                    return "__AUTH_DIRTY"
                } else if flags.contains(.constTproData) {
                    return "__AUTH_TPRO_CONST"
                } else if flags.contains(.constData) {
                    return "__AUTH_CONST"
                } else {
                    return "__AUTH"
                }
            } else {
                if flags.contains(.dirtyData) {
                    return "__DATA_DIRTY"
                } else if flags.contains(.constTproData) {
                    return "__TPRO_CONST"
                } else if flags.contains(.constData) {
                    return "__DATA_CONST"
                } else {
                    return "__DATA"
                }
            }
        case _ where maxProtection.contains(.read):
            if flags.contains(.readOnlyData) {
                return "__READ_ONLY"
            } else {
                return "__LINKEDIT"
            }
        default: return nil
        }
    }
}

extension DyldCacheMappingAndSlideInfo {
    internal func withFileOffset(_ value: UInt64) -> Self {
        var layout = layout
        layout.fileOffset = value
        return .init(layout: layout)
    }

    internal func withSlideInfoFileOffset(_ value: UInt64) -> Self {
        var layout = layout
        layout.slideInfoFileOffset = value
        return .init(layout: layout)
    }
}
