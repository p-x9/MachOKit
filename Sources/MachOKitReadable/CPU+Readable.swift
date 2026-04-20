import Foundation
import MachOKit

extension CPUType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .any: "Any"
        case .vax: "VAX"
        case .mc680x0: "Motorola 68000"
        case .x86: "x86"
        case .i386: "Intel 386"
        case .x86_64: "x86-64"
        case .mc98000: "Motorola 98000"
        case .hppa: "HP PA-RISC"
        case .arm: "ARM"
        case .arm64: "ARM64"
        case .arm64_32: "ARM64 (ILP32)"
        case .mc88000: "Motorola 88000"
        case .sparc: "SPARC"
        case .i860: "Intel i860"
        case .powerpc: "PowerPC"
        case .powerpc64: "PowerPC 64-bit"
        }
    }
}

extension CPUSubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case let .any(type): type.readableDescription
        case let .vax(type): type.readableDescription
        case let .mc680x0(type): type.readableDescription
        case let .i386(type): type.readableDescription
        case let .x86(type): type.readableDescription
        case let .mips(type): type.readableDescription
        case let .mc98000(type): type.readableDescription
        case let .hppa(type): type.readableDescription
        case let .mc88000(type): type.readableDescription
        case let .sparc(type): type.readableDescription
        case let .i860(type): type.readableDescription
        case let .powerpc(type): type.readableDescription
        case let .arm(type): type.readableDescription
        case let .arm64(type): type.readableDescription
        case let .arm64_32(type): type.readableDescription
        }
    }
}

extension CPUAnySubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .multiple: "Multiple"
        case .little_endian: "Little Endian"
        case .big_endian: "Big Endian"
        }
    }
}
extension CPUMC680x0SubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .mc680x0_all: "All"
        case .mc68030: "68030"
        case .mc68040: "68040"
        case .mc68030_only: "68030 Only"
        }
    }
}

extension CPUI386SubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .i386_all: "i386 All"
        case ._386: "386"
        case ._486: "486"
        case ._486sx: "486SX"
        case ._586: "586"
        case .pent: "Pentium"
        case .pentpro: "Pentium Pro"
        case .pentii_m3: "Pentium II M3"
        case .pentii_m5: "Pentium II M5"
        case .celeron: "Celeron"
        case .celeron_mobile: "Celeron Mobile"
        case .pentium_3: "Pentium III"
        case .pentium_3_m: "Pentium III Mobile"
        case .pentium_3_xeon: "Pentium III Xeon"
        case .pentium_m: "Pentium M"
        case .pentium_4: "Pentium 4"
        case .pentium_4_m: "Pentium 4 Mobile"
        case .itanium: "Itanium"
        case .itanium_2: "Itanium 2"
        case .xeon: "Xeon"
        case .xeon_mp: "Xeon MP"
        case .intel_model_all: "Intel Model All"
        }
    }
}

extension CPUX86SubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .x86_all: "x86 All"
        case .x86_64_all: "x86_64 All"
        case .x86_arch1: "x86 Arch1"
        case .x86_64_h: "x86_64h"
        }
    }
}

extension CPUMipsSubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .mips_all: "MIPS All"
        case .mips_r2300: "MIPS R2300"
        case .mips_r2600: "MIPS R2600"
        case .mips_r2800: "MIPS R2800"
        case .mips_r2000a: "MIPS R2000a"
        case .mips_r2000: "MIPS R2000"
        case .mips_r3000a: "MIPS R3000a"
        case .mips_r3000: "MIPS R3000"
        }
    }
}

extension CPUMC98000SubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .mc98000_all: "MC98000 All"
        case .mc98601: "MC98601"
        }
    }
}

extension CPUHPPASubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .hppa_all: "HPPA All"
        case .hppa_7100: "HPPA 7100"
        case .hppa_7100lc: "HPPA 7100LC"
        }
    }
}

extension CPUMC88000SubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .mc88000_all: "MC88000 All"
        case .mc88100: "MC88100"
        case .mc88110: "MC88110"
        }
    }
}

extension CPUSPARCSubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .sparc_all: "SPARC All"
        }
    }
}

extension CPUI860SubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .i860_all: "i860 All"
        case .i860_860: "i860 860"
        }
    }
}

extension CPUPowerPCSubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .powerpc_all: "PowerPC All"
        case .powerpc_601: "PowerPC 601"
        case .powerpc_602: "PowerPC 602"
        case .powerpc_603: "PowerPC 603"
        case .powerpc_603e: "PowerPC 603e"
        case .powerpc_603ev: "PowerPC 603ev"
        case .powerpc_604: "PowerPC 604"
        case .powerpc_604e: "PowerPC 604e"
        case .powerpc_620: "PowerPC 620"
        case .powerpc_750: "PowerPC 750"
        case .powerpc_7400: "PowerPC 7400"
        case .powerpc_7450: "PowerPC 7450"
        case .powerpc_970: "PowerPC 970"
        }
    }
}

extension CPUARMSubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .arm_all: "ARM All"
        case .arm_v4t: "ARM v4T"
        case .arm_v6: "ARM v6"
        case .arm_v5tej: "ARM v5TEJ"
        case .arm_xscale: "ARM XScale"
        case .arm_v7: "ARM v7"
        case .arm_v7f: "ARM v7F"
        case .arm_v7s: "ARM v7S"
        case .arm_v7k: "ARM v7K"
        case .arm_v8: "ARM v8"
        case .arm_v6m: "ARM v6M"
        case .arm_v7m: "ARM v7M"
        case .arm_v7em: "ARM v7EM"
        case .arm_v8m: "ARM v8M"
        }
    }
}

extension CPUARM64SubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .arm64_all: "ARM64 All"
        case .arm64_v8: "ARM64 v8"
        case .arm64e: "ARM64e"
        }
    }
}

extension CPUARM64_32SubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .arm64_32_all: "ARM64_32 All"
        case .arm64_32_v8: "ARM64_32 v8"
        }
    }
}
extension CPUVAXSubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .vax_all: "All"
        case .vax780: "VAX 780"
        case .vax785: "VAX 785"
        case .vax750: "VAX 750"
        case .vax730: "VAX 730"
        case .uvaxi: "UVAX I"
        case .uvaxii: "UVAX II"
        case .vax8200: "VAX 8200"
        case .vax8500: "VAX 8500"
        case .vax8600: "VAX 8600"
        case .vax8650: "VAX 8650"
        case .vax8800: "VAX 8800"
        case .uvaxiii: "UVAX III"
        }
    }
}
