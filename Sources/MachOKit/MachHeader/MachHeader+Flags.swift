//
//  MachHeader+Flags.swift
//
//
//  Created by p-x9 on 2023/11/29.
//
//

import Foundation

extension MachHeader {
    public struct Flags: OptionSet {
        public typealias RawValue = UInt32

        public var rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension MachHeader.Flags {
    public static let noundefs = MachHeader.Flags(
        rawValue: Bit.noundefs.rawValue
    )
    public static let incrlink = MachHeader.Flags(
        rawValue: Bit.incrlink.rawValue
    )
    public static let dyldlink = MachHeader.Flags(
        rawValue: Bit.dyldlink.rawValue
    )
    public static let bindatload = MachHeader.Flags(
        rawValue: Bit.bindatload.rawValue
    )
    public static let prebound = MachHeader.Flags(
        rawValue: Bit.prebound.rawValue
    )
    public static let split_segs = MachHeader.Flags(
        rawValue: Bit.split_segs.rawValue
    )
    public static let lazy_init = MachHeader.Flags(
        rawValue: Bit.lazy_init.rawValue
    )
    public static let twolevel = MachHeader.Flags(
        rawValue: Bit.twolevel.rawValue
    )
    public static let force_flat = MachHeader.Flags(
        rawValue: Bit.force_flat.rawValue
    )
    public static let nomultidefs = MachHeader.Flags(
        rawValue: Bit.nomultidefs.rawValue
    )
    public static let nofixprebinding = MachHeader.Flags(
        rawValue: Bit.nofixprebinding.rawValue
    )
    public static let prebindable = MachHeader.Flags(
        rawValue: Bit.prebindable.rawValue
    )
    public static let allmodsbound = MachHeader.Flags(
        rawValue: Bit.allmodsbound.rawValue
    )
    public static let subsections_via_symbols = MachHeader.Flags(
        rawValue: Bit.subsections_via_symbols.rawValue
    )
    public static let canonical = MachHeader.Flags(
        rawValue: Bit.canonical.rawValue
    )
    public static let weak_defines = MachHeader.Flags(
        rawValue: Bit.weak_defines.rawValue
    )
    public static let binds_to_weak = MachHeader.Flags(
        rawValue: Bit.binds_to_weak.rawValue
    )
    public static let allow_stack_execution = MachHeader.Flags(
        rawValue: Bit.allow_stack_execution.rawValue
    )
    public static let root_safe = MachHeader.Flags(
        rawValue: Bit.root_safe.rawValue
    )
    public static let setuid_safe = MachHeader.Flags(
        rawValue: Bit.setuid_safe.rawValue
    )
    public static let no_reexported_dylibs = MachHeader.Flags(
        rawValue: Bit.no_reexported_dylibs.rawValue
    )
    public static let pie = MachHeader.Flags(
        rawValue: Bit.pie.rawValue
    )
    public static let dead_strippable_dylib = MachHeader.Flags(
        rawValue: Bit.dead_strippable_dylib.rawValue
    )
    public static let has_tlv_descriptors = MachHeader.Flags(
        rawValue: Bit.has_tlv_descriptors.rawValue
    )
    public static let no_heap_execution = MachHeader.Flags(
        rawValue: Bit.no_heap_execution.rawValue
    )
    public static let app_extension_safe = MachHeader.Flags(
        rawValue: Bit.app_extension_safe.rawValue
    )
    public static let nlist_outofsync_with_dyldinfo = MachHeader.Flags(
        rawValue: Bit.nlist_outofsync_with_dyldinfo.rawValue
    )
    public static let sim_support = MachHeader.Flags(
        rawValue: Bit.sim_support.rawValue
    )
    public static let dylib_in_cache = MachHeader.Flags(
        rawValue: Bit.dylib_in_cache.rawValue
    )
}

extension MachHeader.Flags {
    public var bits: [Bit] {
        MachHeader.Flags.Bit.allCases
            .lazy
            .filter {
                contains(.init(rawValue: $0.rawValue))
            }
    }
}
