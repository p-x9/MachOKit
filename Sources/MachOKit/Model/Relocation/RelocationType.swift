//
//  RelocationType.swift
//
//
//  Created by p-x9 on 2024/01/08.
//
//

import Foundation

public enum RelocationType: Sendable {
    case x86(GenericRelocationType)
    case ppc(PPCRelocationType)
    case arm(ARMRelocationType)
    case arm64(ARM64RelocationType)
    case x86_64(X86_64RelocationType)
}

extension RelocationType {
    init?(rawValue: UInt32, for cpuType: CPUType) {
        switch cpuType {
        case .x86:
            guard let type = GenericRelocationType(rawValue: rawValue) else {
                return nil
            }
            self = .x86(type)

        case .x86_64:
            guard let type = X86_64RelocationType(rawValue: rawValue) else {
                return nil
            }
            self = .x86_64(type)

        case .arm:
            guard let type = ARMRelocationType(rawValue: rawValue) else {
                return nil
            }
            self = .arm(type)

        case .arm64:
            guard let type = ARM64RelocationType(rawValue: rawValue) else {
                return nil
            }
            self = .arm64(type)

        case .powerpc:
            guard let type = PPCRelocationType(rawValue: rawValue) else {
                return nil
            }
            self = .ppc(type)

        default:
            return nil
        }
    }
}

public enum GenericRelocationType: UInt32, Sendable {
    /// GENERIC_RELOC_VANILLA
    case vanilla
    /// GENERIC_RELOC_PAIR
    case pair
    /// GENERIC_RELOC_SECTDIFF
    case sectdiff
    /// GENERIC_RELOC_PB_LA_PTR
    case pb_la_ptr
    /// GENERIC_RELOC_LOCAL_SECTDIFF
    case local_sectdiff
    /// GENERIC_RELOC_TLV
    case tlv
    /// GENERIC_RELOC_INVALID
    case invalid = 0xff
}

extension GenericRelocationType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid: "GENERIC_RELOC_INVALID"
        case .vanilla: "GENERIC_RELOC_VANILLA"
        case .pair: "GENERIC_RELOC_PAIR"
        case .sectdiff: "GENERIC_RELOC_SECTDIFF"
        case .pb_la_ptr: "GENERIC_RELOC_PB_LA_PTR"
        case .local_sectdiff: "GENERIC_RELOC_LOCAL_SECTDIFF"
        case .tlv: "GENERIC_RELOC_TLV"
        }
    }
}

public enum PPCRelocationType: UInt32, Sendable {
    /// PPC_RELOC_VANILLA
    case vanilla
    /// PPC_RELOC_PAIR
    case pair
    /// PPC_RELOC_BR14
    case br14
    /// PPC_RELOC_BR24
    case br24
    /// PPC_RELOC_HI16
    case hi16
    /// PPC_RELOC_LO16
    case lo16
    /// PPC_RELOC_HA16
    case ha16
    /// PPC_RELOC_LO14
    case lo14
    /// PPC_RELOC_SECTDIFF
    case sectdiff
    /// PPC_RELOC_PB_LA_PTR
    case pb_la_ptr
    /// PPC_RELOC_HI16_SECTDIFF
    case hi16_sectdiff
    /// PPC_RELOC_LO16_SECTDIFF
    case lo16_sectdiff
    /// PPC_RELOC_HA16_SECTDIFF
    case ha16_sectdiff
    /// PPC_RELOC_JBSR
    case jbsr
    /// PPC_RELOC_LO14_SECTDIFF
    case lo14_sectdiff
    /// PPC_RELOC_LOCAL_SECTDIFF
    case local_sectdiff
}

extension PPCRelocationType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .vanilla: "PPC_RELOC_VANILLA"
        case .pair: "PPC_RELOC_PAIR"
        case .br14: "PPC_RELOC_BR14"
        case .br24: "PPC_RELOC_BR24"
        case .hi16: "PPC_RELOC_HI16"
        case .lo16: "PPC_RELOC_LO16"
        case .ha16: "PPC_RELOC_HA16"
        case .lo14: "PPC_RELOC_LO14"
        case .sectdiff: "PPC_RELOC_SECTDIFF"
        case .pb_la_ptr: "PPC_RELOC_PB_LA_PTR"
        case .hi16_sectdiff: "PPC_RELOC_HI16_SECTDIFF"
        case .lo16_sectdiff: "PPC_RELOC_LO16_SECTDIFF"
        case .ha16_sectdiff: "PPC_RELOC_HA16_SECTDIFF"
        case .jbsr: "PPC_RELOC_JBSR"
        case .lo14_sectdiff: "PPC_RELOC_LO14_SECTDIFF"
        case .local_sectdiff: "PPC_RELOC_LOCAL_SECTDIFF"
        }
    }
}

public enum ARMRelocationType: UInt32, Sendable {
    /// ARM_RELOC_VANILLA
    case reloc_vanilla
    /// ARM_RELOC_PAIR
    case reloc_pair
    /// ARM_RELOC_SECTDIFF
    case reloc_sectdiff
    /// ARM_RELOC_LOCAL_SECTDIFF
    case reloc_local_sectdiff
    /// ARM_RELOC_PB_LA_PTR
    case reloc_pb_la_ptr
    /// ARM_RELOC_BR24
    case reloc_br24
    /// ARM_THUMB_RELOC_BR22
    case thumb_reloc_br22
    /// ARM_THUMB_32BIT_BRANCH
    case thumb_32bit_branch
    /// ARM_RELOC_HALF
    case reloc_half
    /// ARM_RELOC_HALF_SECTDIFF
    case reloc_half_sectdiff
}

extension ARMRelocationType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .reloc_vanilla: "ARM_RELOC_VANILLA"
        case .reloc_pair: "ARM_RELOC_PAIR"
        case .reloc_sectdiff: "ARM_RELOC_SECTDIFF"
        case .reloc_local_sectdiff: "ARM_RELOC_LOCAL_SECTDIFF"
        case .reloc_pb_la_ptr: "ARM_RELOC_PB_LA_PTR"
        case .reloc_br24: "ARM_RELOC_BR24"
        case .thumb_reloc_br22: "ARM_THUMB_RELOC_BR22"
        case .thumb_32bit_branch: "ARM_THUMB_32BIT_BRANCH"
        case .reloc_half: "ARM_RELOC_HALF"
        case .reloc_half_sectdiff: "ARM_RELOC_HALF_SECTDIFF"
        }
    }
}

public enum ARM64RelocationType: UInt32, Sendable {
    /// ARM64_RELOC_UNSIGNED
    case unsigned
    /// ARM64_RELOC_SUBTRACTOR
    case subtractor
    /// ARM64_RELOC_BRANCH26
    case branch26
    /// ARM64_RELOC_PAGE21
    case page21
    /// ARM64_RELOC_PAGEOFF12
    case pageoff12
    /// ARM64_RELOC_GOT_LOAD_PAGE21
    case got_load_page21
    /// ARM64_RELOC_GOT_LOAD_PAGEOFF12
    case got_load_pageoff12
    /// ARM64_RELOC_POINTER_TO_GOT
    case pointer_to_got
    /// ARM64_RELOC_TLVP_LOAD_PAGE21
    case tlvp_load_page21
    /// ARM64_RELOC_TLVP_LOAD_PAGEOFF12
    case tlvp_load_pageoff12
    /// ARM64_RELOC_ADDEND
    case addend
    /// ARM64_RELOC_AUTHENTICATED_POINTER
    case authenticated_pointer
}

extension ARM64RelocationType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unsigned: "ARM64_RELOC_UNSIGNED"
        case .subtractor: "ARM64_RELOC_SUBTRACTOR"
        case .branch26: "ARM64_RELOC_BRANCH26"
        case .page21: "ARM64_RELOC_PAGE21"
        case .pageoff12: "ARM64_RELOC_PAGEOFF12"
        case .got_load_page21: "ARM64_RELOC_GOT_LOAD_PAGE21"
        case .got_load_pageoff12: "ARM64_RELOC_GOT_LOAD_PAGEOFF12"
        case .pointer_to_got: "ARM64_RELOC_POINTER_TO_GOT"
        case .tlvp_load_page21: "ARM64_RELOC_TLVP_LOAD_PAGE21"
        case .tlvp_load_pageoff12: "ARM64_RELOC_TLVP_LOAD_PAGEOFF12"
        case .addend: "ARM64_RELOC_ADDEND"
        case .authenticated_pointer: "ARM64_RELOC_AUTHENTICATED_POINTER"
        }
    }
}

public enum X86_64RelocationType: UInt32, Sendable {
    /// X86_64_RELOC_UNSIGNED
    case unsigned
    /// X86_64_RELOC_SIGNED
    case signed
    /// X86_64_RELOC_BRANCH
    case branch
    /// X86_64_RELOC_GOT_LOAD
    case got_load
    /// X86_64_RELOC_GOT
    case got
    /// X86_64_RELOC_SUBTRACTOR
    case subtractor
    /// X86_64_RELOC_SIGNED_1
    case signed_1
    /// X86_64_RELOC_SIGNED_2
    case signed_2
    /// X86_64_RELOC_SIGNED_4
    case signed_4
    /// X86_64_RELOC_TLV
    case tlv
}

extension X86_64RelocationType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unsigned: "X86_64_RELOC_UNSIGNED"
        case .signed: "X86_64_RELOC_SIGNED"
        case .branch: "X86_64_RELOC_BRANCH"
        case .got_load: "X86_64_RELOC_GOT_LOAD"
        case .got: "X86_64_RELOC_GOT"
        case .subtractor: "X86_64_RELOC_SUBTRACTOR"
        case .signed_1: "X86_64_RELOC_SIGNED_1"
        case .signed_2: "X86_64_RELOC_SIGNED_2"
        case .signed_4: "X86_64_RELOC_SIGNED_4"
        case .tlv: "X86_64_RELOC_TLV"
        }
    }
}
