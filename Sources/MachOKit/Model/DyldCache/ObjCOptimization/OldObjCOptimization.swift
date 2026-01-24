//
//  OldObjCOptimization.swift
//  
//
//  Created by p-x9 on 2024/10/06
//  
//

import Foundation
import MachOKitC

public enum OldObjCOptimization: Sendable {
    case v12(OldObjCOptimization12)
    case v13(OldObjCOptimization13)
    // case v14 unknown
    case v15(OldObjCOptimization15)
    case v16(OldObjCOptimization16)
}

extension OldObjCOptimization {
    public var offset: Int {
        switch self {
        case .v12(let optimization): optimization.offset
        case .v13(let optimization): optimization.offset
        case .v15(let optimization): optimization.offset
        case .v16(let optimization): optimization.offset
        }
    }

    public var version: UInt32 {
        switch self {
        case .v12(let optimization): optimization.version
        case .v13(let optimization): optimization.version
        case .v15(let optimization): optimization.version
        case .v16(let optimization): optimization.version
        }
    }

    public var flags: ObjCOptimizationFlags? {
        switch self {
        case .v12: nil
        case .v13: nil
        case .v15(let optimization): optimization.flags
        case .v16(let optimization): optimization.flags
        }
    }

    /// Relative method list selectors are offsets from this address
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: relative selector's base address
    public func relativeMethodSelectorBaseAddress(
        in cache: DyldCacheLoaded
    ) -> UnsafeRawPointer? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15: return nil
        case .v16(let optimization):
            return optimization.relativeMethodSelectorBaseAddress(in: cache)
        }
    }
}

extension OldObjCOptimization {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRW64(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRW64(in: cache)
        }
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRW32(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRW32(in: cache)
        }
    }

    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRW64(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRW64(in: cache)
        }
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRW32(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRW32(in: cache)
        }
    }
}

extension OldObjCOptimization {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW64? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRW64(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRW64(in: cache)
        }
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW32? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRW32(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRW32(in: cache)
        }
    }
}

extension OldObjCOptimization {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRO64(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRO64(in: cache)
        }
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRO32(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRO32(in: cache)
        }
    }

    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRO64(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRO64(in: cache)
        }
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRO32(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRO32(in: cache)
        }
    }
}

extension OldObjCOptimization {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO64? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRO64(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRO64(in: cache)
        }
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO32? {
        switch self {
        case .v12: return nil
        case .v13: return nil
        case .v15(let optimization):
            return optimization.headerOptimizationRO32(in: cache)
        case .v16(let optimization):
            return optimization.headerOptimizationRO32(in: cache)
        }
    }
}

// MARK: - Load

extension OldObjCOptimization {
    internal static func load(
        from address: UInt64,
        in machO: MachOFile
    ) -> Self? {
        let fileOffset = if let cache = machO.cache {
            cache.fileOffset(of: address)
        } else {
            machO.fileOffset(of: address)
        }

        let offset = if let cache = machO.cache {
            address - cache.mainCacheHeader.sharedRegionStart
        } else {
            machO.fileOffset(of: address)
        }

        guard let fileOffset, let offset else { return nil }

        let version: UInt32 = machO.fileHandle.read(
            offset: fileOffset + numericCast(machO.headerStartOffset)
        )
        switch version {
        case 12:
            return .v12(
                .init(
                    layout: machO.fileHandle.read(
                        offset: fileOffset + numericCast(machO.headerStartOffset)
                    ),
                    offset: numericCast(offset)
                )
            )
        case 13:
            return .v13(
                .init(
                    layout: machO.fileHandle.read(
                        offset: fileOffset + numericCast(machO.headerStartOffset)
                    ),
                    offset: numericCast(offset)
                )
            )
        case 15:
            return .v15(
                .init(
                    layout: machO.fileHandle.read(
                        offset: fileOffset + numericCast(machO.headerStartOffset)
                    ),
                    offset: numericCast(offset)
                )
            )
        case 16:
            return .v16(
                .init(
                    layout: machO.fileHandle.read(
                        offset: fileOffset + numericCast(machO.headerStartOffset)
                    ),
                    offset: numericCast(offset)
                )
            )
        default:
            return nil
        }
    }

    internal static func load(
        from ptr: UnsafeRawPointer,
        offset: Int
    ) -> Self? {
        let version: UInt32 = ptr.autoBoundPointee()
        switch version {
        case 12:
            return .v12(
                .init(
                    layout: ptr.autoBoundPointee(),
                    offset: numericCast(offset)
                )
            )
        case 13:
            return .v13(
                .init(
                    layout: ptr.autoBoundPointee(),
                    offset: numericCast(offset)
                )
            )
        case 15:
            return .v15(
                .init(
                    layout: ptr.autoBoundPointee(),
                    offset: numericCast(offset)
                )
            )
        case 16:
            return .v16(
                .init(
                    layout: ptr.autoBoundPointee(),
                    offset: numericCast(offset)
                )
            )
        default:
            return nil
        }
    }
}

// MARK: - Version specific layout

public struct OldObjCOptimization16: LayoutWrapper, Sendable {
    public typealias Layout = objc_opt_t_16

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
}

public struct OldObjCOptimization15: LayoutWrapper, Sendable {
    public typealias Layout = objc_opt_t_15

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
}

public struct OldObjCOptimization13: LayoutWrapper, Sendable {
    public typealias Layout = objc_opt_t_13

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
}

public struct OldObjCOptimization12: LayoutWrapper, Sendable {
    public typealias Layout = objc_opt_t_12

    public var layout: Layout
    /// offset from start address of main cache
    public let offset: Int
}

// MARK: - Extension of version specific layout

// MARK: flags

extension OldObjCOptimization16 {
    public var flags: ObjCOptimizationFlags {
        .init(rawValue: layout.flags)
    }
}

extension OldObjCOptimization15 {
    public var flags: ObjCOptimizationFlags {
        .init(rawValue: layout.flags)
    }
}

// MARK: relativeMethodSelectorBaseAddress

extension OldObjCOptimization16 {
    /// Relative method list selectors are offsets from this address
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: relative selector's base address
    public func relativeMethodSelectorBaseAddress(
        in cache: DyldCacheLoaded
    ) -> UnsafeRawPointer {
        cache.ptr
            .advanced(by: offset)
            .advanced(
                by: numericCast(layout.relativeMethodSelectorBaseAddressOffset)
            )
    }
}

// MARK: headerOptimizationRW

extension OldObjCOptimization16 {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        _headerOptimizationRW64(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        _headerOptimizationRW32(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }

    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        _headerOptimizationRW64(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        _headerOptimizationRW32(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }
}

extension OldObjCOptimization15 {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        _headerOptimizationRW64(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        _headerOptimizationRW32(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }

    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRW64? {
        _headerOptimizationRW64(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRW32? {
        _headerOptimizationRW32(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }
}

extension OldObjCOptimization16 {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW64? {
        _headerOptimizationRW64(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW32? {
        _headerOptimizationRW32(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }
}

extension OldObjCOptimization15 {
    /// Header optimization rw info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW64? {
        _headerOptimizationRW64(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }

    /// Header optimization rw info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization rw
    public func headerOptimizationRW32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRW32? {
        _headerOptimizationRW32(
            rwOffset: numericCast(layout.headeropt_rw_offset),
            in: cache
        )
    }
}

// MARK: headerOptimizationRO

extension OldObjCOptimization16 {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        _headerOptimizationRO64(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        _headerOptimizationRO32(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }

    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        _headerOptimizationRO64(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        _headerOptimizationRO32(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }
}

extension OldObjCOptimization15 {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        _headerOptimizationRO64(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        _headerOptimizationRO32(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }

    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRO64? {
        _headerOptimizationRO64(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: FullDyldCache
    ) -> ObjCHeaderOptimizationRO32? {
        _headerOptimizationRO32(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }
}

extension OldObjCOptimization16 {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO64? {
        _headerOptimizationRO64(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO32? {
        _headerOptimizationRO32(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }
}

extension OldObjCOptimization15 {
    /// Header optimization ro info for 64bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO64(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO64? {
        _headerOptimizationRO64(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }

    /// Header optimization ro info for 32bit
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: header optimization ro
    public func headerOptimizationRO32(
        in cache: DyldCacheLoaded
    ) -> ObjCHeaderOptimizationRO32? {
        _headerOptimizationRO32(
            roOffset: numericCast(layout.headeropt_ro_offset),
            in: cache
        )
    }
}
