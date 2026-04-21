import Foundation
import MachOKit

extension FileType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .object: "Relocatable Object"
        case .execute: "Executable"
        case .fvmlib: "Fixed VM Library"
        case .core: "Core Dump"
        case .preload: "Preload Executable"
        case .dylib: "Dynamic Library"
        case .dylinker: "Dynamic Linker"
        case .bundle: "Bundle"
        case .dylibStub: "Dynamic Library Stub"
        case .dsym: "Debug Symbols"
        case .kextBundle: "Kernel Extension Bundle"
        case .fileset: "Fileset"
        case .gpuExecute: "GPU Executable"
        case .gpuDylib: "GPU Dynamic Library"
        }
    }
}

extension MachHeader.Flags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .noundefs: "No Undefined Symbols"
        case .incrlink: "Incremental Link"
        case .dyldlink: "Uses Dynamic Linker"
        case .bindatload: "Bind at Load"
        case .prebound: "Prebound"
        case .split_segs: "Split Segments"
        case .lazy_init: "Lazy Initialization"
        case .twolevel: "Two-Level Namespace"
        case .force_flat: "Force Flat Namespace"
        case .nomultidefs: "No Multiple Definitions"
        case .nofixprebinding: "No Fix Prebinding"
        case .prebindable: "Prebindable"
        case .allmodsbound: "All Modules Bound"
        case .subsections_via_symbols: "Subsections via Symbols"
        case .canonical: "Canonical"
        case .weak_defines: "Weak Defines"
        case .binds_to_weak: "Binds to Weak"
        case .allow_stack_execution: "Allow Stack Execution"
        case .root_safe: "Root Safe"
        case .setuid_safe: "Setuid Safe"
        case .no_reexported_dylibs: "No Re-exported Dylibs"
        case .pie: "Position-Independent Executable"
        case .dead_strippable_dylib: "Dead-Strippable Dylib"
        case .has_tlv_descriptors: "Has TLV Descriptors"
        case .no_heap_execution: "No Heap Execution"
        case .app_extension_safe: "App Extension Safe"
        case .nlist_outofsync_with_dyldinfo: "NList Out-of-Sync with Dyld Info"
        case .sim_support: "Simulator Support"
        case .implicit_pagezero: "Implicit __PAGEZERO"
        case .dylib_in_cache: "Dylib in Shared Cache"
        }
    }
}

extension MachHeader.Flags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension MachHeader.Flags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}
