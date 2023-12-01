import Foundation


// MARK: - Any
public enum CPUAnySubType {
    case multiple
    case little_endian
    case big_endian
}

extension CPUAnySubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_MULTIPLE: self = .multiple
        case CPU_SUBTYPE_LITTLE_ENDIAN: self = .little_endian
        case CPU_SUBTYPE_BIG_ENDIAN: self = .big_endian
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .multiple: CPU_SUBTYPE_MULTIPLE
        case .little_endian: CPU_SUBTYPE_LITTLE_ENDIAN
        case .big_endian: CPU_SUBTYPE_BIG_ENDIAN
        }
    }
}

extension CPUAnySubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .multiple: "CPU_SUBTYPE_MULTIPLE"
        case .little_endian: "CPU_SUBTYPE_LITTLE_ENDIAN"
        case .big_endian: "CPU_SUBTYPE_BIG_ENDIAN"
        }
    }

}


// MARK: - VAX
public enum CPUVAXSubType {
    case vax_all
    case vax780
    case vax785
    case vax750
    case vax730
    case uvaxi
    case uvaxii
    case vax8200
    case vax8500
    case vax8600
    case vax8650
    case vax8800
    case uvaxiii
}

extension CPUVAXSubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_VAX_ALL: self = .vax_all
        case CPU_SUBTYPE_VAX780: self = .vax780
        case CPU_SUBTYPE_VAX785: self = .vax785
        case CPU_SUBTYPE_VAX750: self = .vax750
        case CPU_SUBTYPE_VAX730: self = .vax730
        case CPU_SUBTYPE_UVAXI: self = .uvaxi
        case CPU_SUBTYPE_UVAXII: self = .uvaxii
        case CPU_SUBTYPE_VAX8200: self = .vax8200
        case CPU_SUBTYPE_VAX8500: self = .vax8500
        case CPU_SUBTYPE_VAX8600: self = .vax8600
        case CPU_SUBTYPE_VAX8650: self = .vax8650
        case CPU_SUBTYPE_VAX8800: self = .vax8800
        case CPU_SUBTYPE_UVAXIII: self = .uvaxiii
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .vax_all: CPU_SUBTYPE_VAX_ALL
        case .vax780: CPU_SUBTYPE_VAX780
        case .vax785: CPU_SUBTYPE_VAX785
        case .vax750: CPU_SUBTYPE_VAX750
        case .vax730: CPU_SUBTYPE_VAX730
        case .uvaxi: CPU_SUBTYPE_UVAXI
        case .uvaxii: CPU_SUBTYPE_UVAXII
        case .vax8200: CPU_SUBTYPE_VAX8200
        case .vax8500: CPU_SUBTYPE_VAX8500
        case .vax8600: CPU_SUBTYPE_VAX8600
        case .vax8650: CPU_SUBTYPE_VAX8650
        case .vax8800: CPU_SUBTYPE_VAX8800
        case .uvaxiii: CPU_SUBTYPE_UVAXIII
        }
    }
}

extension CPUVAXSubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .vax_all: "CPU_SUBTYPE_VAX_ALL"
        case .vax780: "CPU_SUBTYPE_VAX780"
        case .vax785: "CPU_SUBTYPE_VAX785"
        case .vax750: "CPU_SUBTYPE_VAX750"
        case .vax730: "CPU_SUBTYPE_VAX730"
        case .uvaxi: "CPU_SUBTYPE_UVAXI"
        case .uvaxii: "CPU_SUBTYPE_UVAXII"
        case .vax8200: "CPU_SUBTYPE_VAX8200"
        case .vax8500: "CPU_SUBTYPE_VAX8500"
        case .vax8600: "CPU_SUBTYPE_VAX8600"
        case .vax8650: "CPU_SUBTYPE_VAX8650"
        case .vax8800: "CPU_SUBTYPE_VAX8800"
        case .uvaxiii: "CPU_SUBTYPE_UVAXIII"
        }
    }

}


// MARK: - MC680x0
public enum CPUMC680x0SubType {
    case mc680x0_all
    case mc68030
    case mc68040
    case mc68030_only
}

extension CPUMC680x0SubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_MC680x0_ALL: self = .mc680x0_all
        case CPU_SUBTYPE_MC68030: self = .mc68030
        case CPU_SUBTYPE_MC68040: self = .mc68040
        case CPU_SUBTYPE_MC68030_ONLY: self = .mc68030_only
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .mc680x0_all: CPU_SUBTYPE_MC680x0_ALL
        case .mc68030: CPU_SUBTYPE_MC68030
        case .mc68040: CPU_SUBTYPE_MC68040
        case .mc68030_only: CPU_SUBTYPE_MC68030_ONLY
        }
    }
}

extension CPUMC680x0SubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mc680x0_all: "CPU_SUBTYPE_MC680x0_ALL"
        case .mc68030: "CPU_SUBTYPE_MC68030"
        case .mc68040: "CPU_SUBTYPE_MC68040"
        case .mc68030_only: "CPU_SUBTYPE_MC68030_ONLY"
        }
    }

}


// MARK: - I386
public enum CPUI386SubType {
    case i386_all
    case _386
    case _486
    case _486sx
    case _586
    case pent
    case pentpro
    case pentii_m3
    case pentii_m5
    case celeron
    case celeron_mobile
    case pentium_3
    case pentium_3_m
    case pentium_3_xeon
    case pentium_m
    case pentium_4
    case pentium_4_m
    case itanium
    case itanium_2
    case xeon
    case xeon_mp
    case intel_model_all
}

extension CPUI386SubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_I386_ALL: self = .i386_all
        case CPU_SUBTYPE_386: self = ._386
        case CPU_SUBTYPE_486: self = ._486
        case CPU_SUBTYPE_486SX: self = ._486sx
        case CPU_SUBTYPE_586: self = ._586
        case CPU_SUBTYPE_PENT: self = .pent
        case CPU_SUBTYPE_PENTPRO: self = .pentpro
        case CPU_SUBTYPE_PENTII_M3: self = .pentii_m3
        case CPU_SUBTYPE_PENTII_M5: self = .pentii_m5
        case CPU_SUBTYPE_CELERON: self = .celeron
        case CPU_SUBTYPE_CELERON_MOBILE: self = .celeron_mobile
        case CPU_SUBTYPE_PENTIUM_3: self = .pentium_3
        case CPU_SUBTYPE_PENTIUM_3_M: self = .pentium_3_m
        case CPU_SUBTYPE_PENTIUM_3_XEON: self = .pentium_3_xeon
        case CPU_SUBTYPE_PENTIUM_M: self = .pentium_m
        case CPU_SUBTYPE_PENTIUM_4: self = .pentium_4
        case CPU_SUBTYPE_PENTIUM_4_M: self = .pentium_4_m
        case CPU_SUBTYPE_ITANIUM: self = .itanium
        case CPU_SUBTYPE_ITANIUM_2: self = .itanium_2
        case CPU_SUBTYPE_XEON: self = .xeon
        case CPU_SUBTYPE_XEON_MP: self = .xeon_mp
        case CPU_SUBTYPE_INTEL_MODEL_ALL: self = .intel_model_all
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .i386_all: CPU_SUBTYPE_I386_ALL
        case ._386: CPU_SUBTYPE_386
        case ._486: CPU_SUBTYPE_486
        case ._486sx: CPU_SUBTYPE_486SX
        case ._586: CPU_SUBTYPE_586
        case .pent: CPU_SUBTYPE_PENT
        case .pentpro: CPU_SUBTYPE_PENTPRO
        case .pentii_m3: CPU_SUBTYPE_PENTII_M3
        case .pentii_m5: CPU_SUBTYPE_PENTII_M5
        case .celeron: CPU_SUBTYPE_CELERON
        case .celeron_mobile: CPU_SUBTYPE_CELERON_MOBILE
        case .pentium_3: CPU_SUBTYPE_PENTIUM_3
        case .pentium_3_m: CPU_SUBTYPE_PENTIUM_3_M
        case .pentium_3_xeon: CPU_SUBTYPE_PENTIUM_3_XEON
        case .pentium_m: CPU_SUBTYPE_PENTIUM_M
        case .pentium_4: CPU_SUBTYPE_PENTIUM_4
        case .pentium_4_m: CPU_SUBTYPE_PENTIUM_4_M
        case .itanium: CPU_SUBTYPE_ITANIUM
        case .itanium_2: CPU_SUBTYPE_ITANIUM_2
        case .xeon: CPU_SUBTYPE_XEON
        case .xeon_mp: CPU_SUBTYPE_XEON_MP
        case .intel_model_all: CPU_SUBTYPE_INTEL_MODEL_ALL
        }
    }
}

extension CPUI386SubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .i386_all: "CPU_SUBTYPE_I386_ALL"
        case ._386: "CPU_SUBTYPE_386"
        case ._486: "CPU_SUBTYPE_486"
        case ._486sx: "CPU_SUBTYPE_486SX"
        case ._586: "CPU_SUBTYPE_586"
        case .pent: "CPU_SUBTYPE_PENT"
        case .pentpro: "CPU_SUBTYPE_PENTPRO"
        case .pentii_m3: "CPU_SUBTYPE_PENTII_M3"
        case .pentii_m5: "CPU_SUBTYPE_PENTII_M5"
        case .celeron: "CPU_SUBTYPE_CELERON"
        case .celeron_mobile: "CPU_SUBTYPE_CELERON_MOBILE"
        case .pentium_3: "CPU_SUBTYPE_PENTIUM_3"
        case .pentium_3_m: "CPU_SUBTYPE_PENTIUM_3_M"
        case .pentium_3_xeon: "CPU_SUBTYPE_PENTIUM_3_XEON"
        case .pentium_m: "CPU_SUBTYPE_PENTIUM_M"
        case .pentium_4: "CPU_SUBTYPE_PENTIUM_4"
        case .pentium_4_m: "CPU_SUBTYPE_PENTIUM_4_M"
        case .itanium: "CPU_SUBTYPE_ITANIUM"
        case .itanium_2: "CPU_SUBTYPE_ITANIUM_2"
        case .xeon: "CPU_SUBTYPE_XEON"
        case .xeon_mp: "CPU_SUBTYPE_XEON_MP"
        case .intel_model_all: "CPU_SUBTYPE_INTEL_MODEL_ALL"
        }
    }

}


// MARK: - X86
public enum CPUX86SubType {
    case x86_all
    case x86_64_all
    case x86_arch1
    case x86_64_h
}

extension CPUX86SubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_X86_ALL: self = .x86_all
        case CPU_SUBTYPE_X86_64_ALL: self = .x86_64_all
        case CPU_SUBTYPE_X86_ARCH1: self = .x86_arch1
        case CPU_SUBTYPE_X86_64_H: self = .x86_64_h
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .x86_all: CPU_SUBTYPE_X86_ALL
        case .x86_64_all: CPU_SUBTYPE_X86_64_ALL
        case .x86_arch1: CPU_SUBTYPE_X86_ARCH1
        case .x86_64_h: CPU_SUBTYPE_X86_64_H
        }
    }
}

extension CPUX86SubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .x86_all: "CPU_SUBTYPE_X86_ALL"
        case .x86_64_all: "CPU_SUBTYPE_X86_64_ALL"
        case .x86_arch1: "CPU_SUBTYPE_X86_ARCH1"
        case .x86_64_h: "CPU_SUBTYPE_X86_64_H"
        }
    }

}


// MARK: - Mips
public enum CPUMipsSubType {
    case mips_all
    case mips_r2300
    case mips_r2600
    case mips_r2800
    case mips_r2000a
    case mips_r2000
    case mips_r3000a
    case mips_r3000
}

extension CPUMipsSubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_MIPS_ALL: self = .mips_all
        case CPU_SUBTYPE_MIPS_R2300: self = .mips_r2300
        case CPU_SUBTYPE_MIPS_R2600: self = .mips_r2600
        case CPU_SUBTYPE_MIPS_R2800: self = .mips_r2800
        case CPU_SUBTYPE_MIPS_R2000a: self = .mips_r2000a
        case CPU_SUBTYPE_MIPS_R2000: self = .mips_r2000
        case CPU_SUBTYPE_MIPS_R3000a: self = .mips_r3000a
        case CPU_SUBTYPE_MIPS_R3000: self = .mips_r3000
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .mips_all: CPU_SUBTYPE_MIPS_ALL
        case .mips_r2300: CPU_SUBTYPE_MIPS_R2300
        case .mips_r2600: CPU_SUBTYPE_MIPS_R2600
        case .mips_r2800: CPU_SUBTYPE_MIPS_R2800
        case .mips_r2000a: CPU_SUBTYPE_MIPS_R2000a
        case .mips_r2000: CPU_SUBTYPE_MIPS_R2000
        case .mips_r3000a: CPU_SUBTYPE_MIPS_R3000a
        case .mips_r3000: CPU_SUBTYPE_MIPS_R3000
        }
    }
}

extension CPUMipsSubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mips_all: "CPU_SUBTYPE_MIPS_ALL"
        case .mips_r2300: "CPU_SUBTYPE_MIPS_R2300"
        case .mips_r2600: "CPU_SUBTYPE_MIPS_R2600"
        case .mips_r2800: "CPU_SUBTYPE_MIPS_R2800"
        case .mips_r2000a: "CPU_SUBTYPE_MIPS_R2000a"
        case .mips_r2000: "CPU_SUBTYPE_MIPS_R2000"
        case .mips_r3000a: "CPU_SUBTYPE_MIPS_R3000a"
        case .mips_r3000: "CPU_SUBTYPE_MIPS_R3000"
        }
    }

}


// MARK: - MC98000
public enum CPUMC98000SubType {
    case mc98000_all
    case mc98601
}

extension CPUMC98000SubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_MC98000_ALL: self = .mc98000_all
        case CPU_SUBTYPE_MC98601: self = .mc98601
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .mc98000_all: CPU_SUBTYPE_MC98000_ALL
        case .mc98601: CPU_SUBTYPE_MC98601
        }
    }
}

extension CPUMC98000SubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mc98000_all: "CPU_SUBTYPE_MC98000_ALL"
        case .mc98601: "CPU_SUBTYPE_MC98601"
        }
    }

}


// MARK: - HPPA
public enum CPUHPPASubType {
    case hppa_all
    case hppa_7100
    case hppa_7100lc
}

extension CPUHPPASubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_HPPA_ALL: self = .hppa_all
        case CPU_SUBTYPE_HPPA_7100: self = .hppa_7100
        case CPU_SUBTYPE_HPPA_7100LC: self = .hppa_7100lc
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .hppa_all: CPU_SUBTYPE_HPPA_ALL
        case .hppa_7100: CPU_SUBTYPE_HPPA_7100
        case .hppa_7100lc: CPU_SUBTYPE_HPPA_7100LC
        }
    }
}

extension CPUHPPASubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .hppa_all: "CPU_SUBTYPE_HPPA_ALL"
        case .hppa_7100: "CPU_SUBTYPE_HPPA_7100"
        case .hppa_7100lc: "CPU_SUBTYPE_HPPA_7100LC"
        }
    }

}


// MARK: - MC88000
public enum CPUMC88000SubType {
    case mc88000_all
    case mc88100
    case mc88110
}

extension CPUMC88000SubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_MC88000_ALL: self = .mc88000_all
        case CPU_SUBTYPE_MC88100: self = .mc88100
        case CPU_SUBTYPE_MC88110: self = .mc88110
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .mc88000_all: CPU_SUBTYPE_MC88000_ALL
        case .mc88100: CPU_SUBTYPE_MC88100
        case .mc88110: CPU_SUBTYPE_MC88110
        }
    }
}

extension CPUMC88000SubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mc88000_all: "CPU_SUBTYPE_MC88000_ALL"
        case .mc88100: "CPU_SUBTYPE_MC88100"
        case .mc88110: "CPU_SUBTYPE_MC88110"
        }
    }

}


// MARK: - SPARC
public enum CPUSPARCSubType {
    case sparc_all
}

extension CPUSPARCSubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_SPARC_ALL: self = .sparc_all
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .sparc_all: CPU_SUBTYPE_SPARC_ALL
        }
    }
}

extension CPUSPARCSubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sparc_all: "CPU_SUBTYPE_SPARC_ALL"
        }
    }

}


// MARK: - I860
public enum CPUI860SubType {
    case i860_all
    case i860_860
}

extension CPUI860SubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_I860_ALL: self = .i860_all
        case CPU_SUBTYPE_I860_860: self = .i860_860
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .i860_all: CPU_SUBTYPE_I860_ALL
        case .i860_860: CPU_SUBTYPE_I860_860
        }
    }
}

extension CPUI860SubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .i860_all: "CPU_SUBTYPE_I860_ALL"
        case .i860_860: "CPU_SUBTYPE_I860_860"
        }
    }

}


// MARK: - PowerPC
public enum CPUPowerPCSubType {
    case powerpc_all
    case powerpc_601
    case powerpc_602
    case powerpc_603
    case powerpc_603e
    case powerpc_603ev
    case powerpc_604
    case powerpc_604e
    case powerpc_620
    case powerpc_750
    case powerpc_7400
    case powerpc_7450
    case powerpc_970
}

extension CPUPowerPCSubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_POWERPC_ALL: self = .powerpc_all
        case CPU_SUBTYPE_POWERPC_601: self = .powerpc_601
        case CPU_SUBTYPE_POWERPC_602: self = .powerpc_602
        case CPU_SUBTYPE_POWERPC_603: self = .powerpc_603
        case CPU_SUBTYPE_POWERPC_603e: self = .powerpc_603e
        case CPU_SUBTYPE_POWERPC_603ev: self = .powerpc_603ev
        case CPU_SUBTYPE_POWERPC_604: self = .powerpc_604
        case CPU_SUBTYPE_POWERPC_604e: self = .powerpc_604e
        case CPU_SUBTYPE_POWERPC_620: self = .powerpc_620
        case CPU_SUBTYPE_POWERPC_750: self = .powerpc_750
        case CPU_SUBTYPE_POWERPC_7400: self = .powerpc_7400
        case CPU_SUBTYPE_POWERPC_7450: self = .powerpc_7450
        case CPU_SUBTYPE_POWERPC_970: self = .powerpc_970
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .powerpc_all: CPU_SUBTYPE_POWERPC_ALL
        case .powerpc_601: CPU_SUBTYPE_POWERPC_601
        case .powerpc_602: CPU_SUBTYPE_POWERPC_602
        case .powerpc_603: CPU_SUBTYPE_POWERPC_603
        case .powerpc_603e: CPU_SUBTYPE_POWERPC_603e
        case .powerpc_603ev: CPU_SUBTYPE_POWERPC_603ev
        case .powerpc_604: CPU_SUBTYPE_POWERPC_604
        case .powerpc_604e: CPU_SUBTYPE_POWERPC_604e
        case .powerpc_620: CPU_SUBTYPE_POWERPC_620
        case .powerpc_750: CPU_SUBTYPE_POWERPC_750
        case .powerpc_7400: CPU_SUBTYPE_POWERPC_7400
        case .powerpc_7450: CPU_SUBTYPE_POWERPC_7450
        case .powerpc_970: CPU_SUBTYPE_POWERPC_970
        }
    }
}

extension CPUPowerPCSubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .powerpc_all: "CPU_SUBTYPE_POWERPC_ALL"
        case .powerpc_601: "CPU_SUBTYPE_POWERPC_601"
        case .powerpc_602: "CPU_SUBTYPE_POWERPC_602"
        case .powerpc_603: "CPU_SUBTYPE_POWERPC_603"
        case .powerpc_603e: "CPU_SUBTYPE_POWERPC_603e"
        case .powerpc_603ev: "CPU_SUBTYPE_POWERPC_603ev"
        case .powerpc_604: "CPU_SUBTYPE_POWERPC_604"
        case .powerpc_604e: "CPU_SUBTYPE_POWERPC_604e"
        case .powerpc_620: "CPU_SUBTYPE_POWERPC_620"
        case .powerpc_750: "CPU_SUBTYPE_POWERPC_750"
        case .powerpc_7400: "CPU_SUBTYPE_POWERPC_7400"
        case .powerpc_7450: "CPU_SUBTYPE_POWERPC_7450"
        case .powerpc_970: "CPU_SUBTYPE_POWERPC_970"
        }
    }

}


// MARK: - ARM
public enum CPUARMSubType {
    case arm_all
    case arm_v4t
    case arm_v6
    case arm_v5tej
    case arm_xscale
    case arm_v7
    case arm_v7f
    case arm_v7s
    case arm_v7k
    case arm_v8
    case arm_v6m
    case arm_v7m
    case arm_v7em
    case arm_v8m
}

extension CPUARMSubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_ARM_ALL: self = .arm_all
        case CPU_SUBTYPE_ARM_V4T: self = .arm_v4t
        case CPU_SUBTYPE_ARM_V6: self = .arm_v6
        case CPU_SUBTYPE_ARM_V5TEJ: self = .arm_v5tej
        case CPU_SUBTYPE_ARM_XSCALE: self = .arm_xscale
        case CPU_SUBTYPE_ARM_V7: self = .arm_v7
        case CPU_SUBTYPE_ARM_V7F: self = .arm_v7f
        case CPU_SUBTYPE_ARM_V7S: self = .arm_v7s
        case CPU_SUBTYPE_ARM_V7K: self = .arm_v7k
        case CPU_SUBTYPE_ARM_V8: self = .arm_v8
        case CPU_SUBTYPE_ARM_V6M: self = .arm_v6m
        case CPU_SUBTYPE_ARM_V7M: self = .arm_v7m
        case CPU_SUBTYPE_ARM_V7EM: self = .arm_v7em
        case CPU_SUBTYPE_ARM_V8M: self = .arm_v8m
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .arm_all: CPU_SUBTYPE_ARM_ALL
        case .arm_v4t: CPU_SUBTYPE_ARM_V4T
        case .arm_v6: CPU_SUBTYPE_ARM_V6
        case .arm_v5tej: CPU_SUBTYPE_ARM_V5TEJ
        case .arm_xscale: CPU_SUBTYPE_ARM_XSCALE
        case .arm_v7: CPU_SUBTYPE_ARM_V7
        case .arm_v7f: CPU_SUBTYPE_ARM_V7F
        case .arm_v7s: CPU_SUBTYPE_ARM_V7S
        case .arm_v7k: CPU_SUBTYPE_ARM_V7K
        case .arm_v8: CPU_SUBTYPE_ARM_V8
        case .arm_v6m: CPU_SUBTYPE_ARM_V6M
        case .arm_v7m: CPU_SUBTYPE_ARM_V7M
        case .arm_v7em: CPU_SUBTYPE_ARM_V7EM
        case .arm_v8m: CPU_SUBTYPE_ARM_V8M
        }
    }
}

extension CPUARMSubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .arm_all: "CPU_SUBTYPE_ARM_ALL"
        case .arm_v4t: "CPU_SUBTYPE_ARM_V4T"
        case .arm_v6: "CPU_SUBTYPE_ARM_V6"
        case .arm_v5tej: "CPU_SUBTYPE_ARM_V5TEJ"
        case .arm_xscale: "CPU_SUBTYPE_ARM_XSCALE"
        case .arm_v7: "CPU_SUBTYPE_ARM_V7"
        case .arm_v7f: "CPU_SUBTYPE_ARM_V7F"
        case .arm_v7s: "CPU_SUBTYPE_ARM_V7S"
        case .arm_v7k: "CPU_SUBTYPE_ARM_V7K"
        case .arm_v8: "CPU_SUBTYPE_ARM_V8"
        case .arm_v6m: "CPU_SUBTYPE_ARM_V6M"
        case .arm_v7m: "CPU_SUBTYPE_ARM_V7M"
        case .arm_v7em: "CPU_SUBTYPE_ARM_V7EM"
        case .arm_v8m: "CPU_SUBTYPE_ARM_V8M"
        }
    }

}


// MARK: - ARM64
public enum CPUARM64SubType {
    case arm64_all
    case arm64_v8
    case arm64e
}

extension CPUARM64SubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_ARM64_ALL: self = .arm64_all
        case CPU_SUBTYPE_ARM64_V8: self = .arm64_v8
        case CPU_SUBTYPE_ARM64E: self = .arm64e
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .arm64_all: CPU_SUBTYPE_ARM64_ALL
        case .arm64_v8: CPU_SUBTYPE_ARM64_V8
        case .arm64e: CPU_SUBTYPE_ARM64E
        }
    }
}

extension CPUARM64SubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .arm64_all: "CPU_SUBTYPE_ARM64_ALL"
        case .arm64_v8: "CPU_SUBTYPE_ARM64_V8"
        case .arm64e: "CPU_SUBTYPE_ARM64E"
        }
    }

}


// MARK: - ARM64_32
public enum CPUARM64_32SubType {
    case arm64_32_all
    case arm64_32_v8
}

extension CPUARM64_32SubType: RawRepresentable {
    public typealias RawValue = cpu_subtype_t

    public init?(rawValue: RawValue) {
        switch rawValue {
        case CPU_SUBTYPE_ARM64_32_ALL: self = .arm64_32_all
        case CPU_SUBTYPE_ARM64_32_V8: self = .arm64_32_v8
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .arm64_32_all: CPU_SUBTYPE_ARM64_32_ALL
        case .arm64_32_v8: CPU_SUBTYPE_ARM64_32_V8
        }
    }
}

extension CPUARM64_32SubType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .arm64_32_all: "CPU_SUBTYPE_ARM64_32_ALL"
        case .arm64_32_v8: "CPU_SUBTYPE_ARM64_32_V8"
        }
    }

}

/*
 I386 series declarations cannot be used from swift
 because macro functions are used.
 */
private let CPU_SUBTYPE_I386_ALL = cpu_subtype_t(3 + (0 << 4))
private let CPU_SUBTYPE_386 = cpu_subtype_t(3 + (0 << 4))
private let CPU_SUBTYPE_486 = cpu_subtype_t(4 + (0 << 4))
private let CPU_SUBTYPE_486SX = cpu_subtype_t(4 + (8 << 4)) // 8 << 4 = 128
private let CPU_SUBTYPE_586 = cpu_subtype_t(5 + (0 << 4))
private let CPU_SUBTYPE_PENT = cpu_subtype_t(5 + (0 << 4))
private let CPU_SUBTYPE_PENTPRO = cpu_subtype_t(6 + (1 << 4))
private let CPU_SUBTYPE_PENTII_M3 = cpu_subtype_t(6 + (3 << 4))
private let CPU_SUBTYPE_PENTII_M5 = cpu_subtype_t(6 + (5 << 4))
private let CPU_SUBTYPE_CELERON = cpu_subtype_t(7 + (6 << 4))
private let CPU_SUBTYPE_CELERON_MOBILE = cpu_subtype_t(7 + (7 << 4))
private let CPU_SUBTYPE_PENTIUM_3 = cpu_subtype_t(8 + (0 << 4))
private let CPU_SUBTYPE_PENTIUM_3_M = cpu_subtype_t(8 + (1 << 4))
private let CPU_SUBTYPE_PENTIUM_3_XEON = cpu_subtype_t(8 + (2 << 4))
private let CPU_SUBTYPE_PENTIUM_M = cpu_subtype_t(9 + (0 << 4))
private let CPU_SUBTYPE_PENTIUM_4 = cpu_subtype_t(10 + (0 << 4))
private let CPU_SUBTYPE_PENTIUM_4_M = cpu_subtype_t(10 + (1 << 4))
private let CPU_SUBTYPE_ITANIUM = cpu_subtype_t(11 + (0 << 4))
private let CPU_SUBTYPE_ITANIUM_2 = cpu_subtype_t(11 + (1 << 4))
private let CPU_SUBTYPE_XEON = cpu_subtype_t(12 + (0 << 4))
private let CPU_SUBTYPE_XEON_MP = cpu_subtype_t(12 + (1 << 4))