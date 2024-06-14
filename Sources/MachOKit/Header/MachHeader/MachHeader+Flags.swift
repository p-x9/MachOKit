//
//  MachHeader+Flags.swift
//
//
//  Created by p-x9 on 2023/11/29.
//
//

import Foundation

extension MachHeader {
    public struct Flags: BitFlags {
        public typealias RawValue = UInt32

        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension MachHeader.Flags {
    /// MH_NOUNDEFS
    public static let noundefs = MachHeader.Flags(
        rawValue: Bit.noundefs.rawValue
    )
    /// MH_INCRLINK
    public static let incrlink = MachHeader.Flags(
        rawValue: Bit.incrlink.rawValue
    )
    /// MH_DYLDLINK
    public static let dyldlink = MachHeader.Flags(
        rawValue: Bit.dyldlink.rawValue
    )
    /// MH_BINDATLOAD
    public static let bindatload = MachHeader.Flags(
        rawValue: Bit.bindatload.rawValue
    )
    /// MH_PREBOUND
    public static let prebound = MachHeader.Flags(
        rawValue: Bit.prebound.rawValue
    )
    /// MH_SPLIT_SEGS
    public static let split_segs = MachHeader.Flags(
        rawValue: Bit.split_segs.rawValue
    )
    /// MH_LAZY_INIT
    public static let lazy_init = MachHeader.Flags(
        rawValue: Bit.lazy_init.rawValue
    )
    /// MH_TWOLEVEL
    public static let twolevel = MachHeader.Flags(
        rawValue: Bit.twolevel.rawValue
    )
    /// MH_FORCE_FLAT
    public static let force_flat = MachHeader.Flags(
        rawValue: Bit.force_flat.rawValue
    )
    /// MH_NOMULTIDEFS
    public static let nomultidefs = MachHeader.Flags(
        rawValue: Bit.nomultidefs.rawValue
    )
    /// MH_NOFIXPREBINDING
    public static let nofixprebinding = MachHeader.Flags(
        rawValue: Bit.nofixprebinding.rawValue
    )
    /// MH_PREBINDABLE
    public static let prebindable = MachHeader.Flags(
        rawValue: Bit.prebindable.rawValue
    )
    /// MH_ALLMODSBOUND
    public static let allmodsbound = MachHeader.Flags(
        rawValue: Bit.allmodsbound.rawValue
    )
    /// MH_SUBSECTIONS_VIA_SYMBOLS
    public static let subsections_via_symbols = MachHeader.Flags(
        rawValue: Bit.subsections_via_symbols.rawValue
    )
    /// MH_CANONICAL
    public static let canonical = MachHeader.Flags(
        rawValue: Bit.canonical.rawValue
    )
    /// MH_WEAK_DEFINES
    public static let weak_defines = MachHeader.Flags(
        rawValue: Bit.weak_defines.rawValue
    )
    /// MH_BINDS_TO_WEAK
    public static let binds_to_weak = MachHeader.Flags(
        rawValue: Bit.binds_to_weak.rawValue
    )
    /// MH_ALLOW_STACK_EXECUTION
    public static let allow_stack_execution = MachHeader.Flags(
        rawValue: Bit.allow_stack_execution.rawValue
    )
    /// MH_ROOT_SAFE
    public static let root_safe = MachHeader.Flags(
        rawValue: Bit.root_safe.rawValue
    )
    /// MH_SETUID_SAFE
    public static let setuid_safe = MachHeader.Flags(
        rawValue: Bit.setuid_safe.rawValue
    )
    /// MH_NO_REEXPORTED_DYLIBS
    public static let no_reexported_dylibs = MachHeader.Flags(
        rawValue: Bit.no_reexported_dylibs.rawValue
    )
    /// MH_PIE
    public static let pie = MachHeader.Flags(
        rawValue: Bit.pie.rawValue
    )
    /// MH_DEAD_STRIPPABLE_DYLIB
    public static let dead_strippable_dylib = MachHeader.Flags(
        rawValue: Bit.dead_strippable_dylib.rawValue
    )
    /// MH_HAS_TLV_DESCRIPTORS
    public static let has_tlv_descriptors = MachHeader.Flags(
        rawValue: Bit.has_tlv_descriptors.rawValue
    )
    /// MH_NO_HEAP_EXECUTION
    public static let no_heap_execution = MachHeader.Flags(
        rawValue: Bit.no_heap_execution.rawValue
    )
    /// MH_APP_EXTENSION_SAFE
    public static let app_extension_safe = MachHeader.Flags(
        rawValue: Bit.app_extension_safe.rawValue
    )
    /// MH_NLIST_OUTOFSYNC_WITH_DYLDINFO
    public static let nlist_outofsync_with_dyldinfo = MachHeader.Flags(
        rawValue: Bit.nlist_outofsync_with_dyldinfo.rawValue
    )
    /// MH_SIM_SUPPORT
    public static let sim_support = MachHeader.Flags(
        rawValue: Bit.sim_support.rawValue
    )
    /// MH_DYLIB_IN_CACHE
    public static let dylib_in_cache = MachHeader.Flags(
        rawValue: Bit.dylib_in_cache.rawValue
    )
}
