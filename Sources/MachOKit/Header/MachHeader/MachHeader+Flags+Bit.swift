//
//  MachHeader+Flags+Bits.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

extension MachHeader.Flags {
    public enum Bit: CaseIterable {
        case noundefs
        case incrlink
        case dyldlink
        case bindatload
        case prebound
        case split_segs
        case lazy_init
        case twolevel
        case force_flat
        case nomultidefs
        case nofixprebinding
        case prebindable
        case allmodsbound
        case subsections_via_symbols
        case canonical
        case weak_defines
        case binds_to_weak
        case allow_stack_execution
        case root_safe
        case setuid_safe
        case no_reexported_dylibs
        case pie
        case dead_strippable_dylib
        case has_tlv_descriptors
        case no_heap_execution
        case app_extension_safe
        case nlist_outofsync_with_dyldinfo
        case sim_support
        case dylib_in_cache
    }
}

extension MachHeader.Flags.Bit: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: UInt32) {
        switch rawValue {
        case RawValue(MH_NOUNDEFS): self = .noundefs
        case RawValue(MH_INCRLINK): self = .incrlink
        case RawValue(MH_DYLDLINK): self = .dyldlink
        case RawValue(MH_BINDATLOAD): self = .bindatload
        case RawValue(MH_PREBOUND): self = .prebound
        case RawValue(MH_SPLIT_SEGS): self = .split_segs
        case RawValue(MH_LAZY_INIT): self = .lazy_init
        case RawValue(MH_TWOLEVEL): self = .twolevel
        case RawValue(MH_FORCE_FLAT): self = .force_flat
        case RawValue(MH_NOMULTIDEFS): self = .nomultidefs
        case RawValue(MH_NOFIXPREBINDING): self = .nofixprebinding
        case RawValue(MH_PREBINDABLE): self = .prebindable
        case RawValue(MH_ALLMODSBOUND): self = .allmodsbound
        case RawValue(MH_SUBSECTIONS_VIA_SYMBOLS): self = .subsections_via_symbols
        case RawValue(MH_CANONICAL): self = .canonical
        case RawValue(MH_WEAK_DEFINES): self = .weak_defines
        case RawValue(MH_BINDS_TO_WEAK): self = .binds_to_weak
        case RawValue(MH_ALLOW_STACK_EXECUTION): self = .allow_stack_execution
        case RawValue(MH_ROOT_SAFE): self = .root_safe
        case RawValue(MH_SETUID_SAFE): self = .setuid_safe
        case RawValue(MH_NO_REEXPORTED_DYLIBS): self = .no_reexported_dylibs
        case RawValue(MH_PIE): self = .pie
        case RawValue(MH_DEAD_STRIPPABLE_DYLIB): self = .dead_strippable_dylib
        case RawValue(MH_HAS_TLV_DESCRIPTORS): self = .has_tlv_descriptors
        case RawValue(MH_NO_HEAP_EXECUTION): self = .no_heap_execution
        case RawValue(MH_APP_EXTENSION_SAFE): self = .app_extension_safe
        case RawValue(MH_NLIST_OUTOFSYNC_WITH_DYLDINFO): self = .nlist_outofsync_with_dyldinfo
        case RawValue(MH_SIM_SUPPORT): self = .sim_support
        case RawValue(MH_DYLIB_IN_CACHE): self = .dylib_in_cache
        default: return nil
        }
    }

    public var rawValue: UInt32 {
        switch self {
        case .noundefs: RawValue(MH_NOUNDEFS)
        case .incrlink: RawValue(MH_INCRLINK)
        case .dyldlink: RawValue(MH_DYLDLINK)
        case .bindatload: RawValue(MH_BINDATLOAD)
        case .prebound: RawValue(MH_PREBOUND)
        case .split_segs: RawValue(MH_SPLIT_SEGS)
        case .lazy_init: RawValue(MH_LAZY_INIT)
        case .twolevel: RawValue(MH_TWOLEVEL)
        case .force_flat: RawValue(MH_FORCE_FLAT)
        case .nomultidefs: RawValue(MH_NOMULTIDEFS)
        case .nofixprebinding: RawValue(MH_NOFIXPREBINDING)
        case .prebindable: RawValue(MH_PREBINDABLE)
        case .allmodsbound: RawValue(MH_ALLMODSBOUND)
        case .subsections_via_symbols: RawValue(MH_SUBSECTIONS_VIA_SYMBOLS)
        case .canonical: RawValue(MH_CANONICAL)
        case .weak_defines: RawValue(MH_WEAK_DEFINES)
        case .binds_to_weak: RawValue(MH_BINDS_TO_WEAK)
        case .allow_stack_execution: RawValue(MH_ALLOW_STACK_EXECUTION)
        case .root_safe: RawValue(MH_ROOT_SAFE)
        case .setuid_safe: RawValue(MH_SETUID_SAFE)
        case .no_reexported_dylibs: RawValue(MH_NO_REEXPORTED_DYLIBS)
        case .pie: RawValue(MH_PIE)
        case .dead_strippable_dylib: RawValue(MH_DEAD_STRIPPABLE_DYLIB)
        case .has_tlv_descriptors: RawValue(MH_HAS_TLV_DESCRIPTORS)
        case .no_heap_execution: RawValue(MH_NO_HEAP_EXECUTION)
        case .app_extension_safe: RawValue(MH_APP_EXTENSION_SAFE)
        case .nlist_outofsync_with_dyldinfo: RawValue(MH_NLIST_OUTOFSYNC_WITH_DYLDINFO)
        case .sim_support: RawValue(MH_SIM_SUPPORT)
        case .dylib_in_cache: RawValue(MH_DYLIB_IN_CACHE)
        }
    }
}

extension MachHeader.Flags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noundefs: "MH_NOUNDEFS"
        case .incrlink: "MH_INCRLINK"
        case .dyldlink: "MH_DYLDLINK"
        case .bindatload: "MH_BINDATLOAD"
        case .prebound: "MH_PREBOUND"
        case .split_segs: "MH_SPLIT_SEGS"
        case .lazy_init: "MH_LAZY_INIT"
        case .twolevel: "MH_TWOLEVEL"
        case .force_flat: "MH_FORCE_FLAT"
        case .nomultidefs: "MH_NOMULTIDEFS"
        case .nofixprebinding: "MH_NOFIXPREBINDING"
        case .prebindable: "MH_PREBINDABLE"
        case .allmodsbound: "MH_ALLMODSBOUND"
        case .subsections_via_symbols: "MH_SUBSECTIONS_VIA_SYMBOLS"
        case .canonical: "MH_CANONICAL"
        case .weak_defines: "MH_WEAK_DEFINES"
        case .binds_to_weak: "MH_BINDS_TO_WEAK"
        case .allow_stack_execution: "MH_ALLOW_STACK_EXECUTION"
        case .root_safe: "MH_ROOT_SAFE"
        case .setuid_safe: "MH_SETUID_SAFE"
        case .no_reexported_dylibs: "MH_NO_REEXPORTED_DYLIBS"
        case .pie: "MH_PIE"
        case .dead_strippable_dylib: "MH_DEAD_STRIPPABLE_DYLIB"
        case .has_tlv_descriptors: "MH_HAS_TLV_DESCRIPTORS"
        case .no_heap_execution: "MH_NO_HEAP_EXECUTION"
        case .app_extension_safe: "MH_APP_EXTENSION_SAFE"
        case .nlist_outofsync_with_dyldinfo: "MH_NLIST_OUTOFSYNC_WITH_DYLDINFO"
        case .sim_support: "MH_SIM_SUPPORT"
        case .dylib_in_cache: "MH_DYLIB_IN_CACHE"
        }
    }
}
