//
//  CPUType.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public enum CPUType: Equatable, CaseIterable {
    /// CPU_TYPE_ANY
    case any
    /// CPU_TYPE_VAX
    case vax
    /// CPU_TYPE_MC680x0
    case mc680x0
    /// CPU_TYPE_X86
    case x86
    /// CPU_TYPE_I386
    case i386
    /// CPU_TYPE_X86_64
    case x86_64
    /// CPU_TYPE_MC98000
    case mc98000
    /// CPU_TYPE_HPPA
    case hppa
    /// CPU_TYPE_ARM
    case arm
    /// CPU_TYPE_ARM64
    case arm64
    /// CPU_TYPE_ARM64_32
    case arm64_32
    /// CPU_TYPE_MC88000
    case mc88000
    /// CPU_TYPE_SPARC
    case sparc
    /// CPU_TYPE_I860
    case i860
    /// CPU_TYPE_POWERPC
    case powerpc
    /// CPU_TYPE_POWERPC64
    case powerpc64
}

extension CPUType: RawRepresentable {
    public typealias RawValue = cpu_type_t

    public init?(rawValue: cpu_type_t) {
        switch rawValue {
        case RawValue(CPU_TYPE_ANY): self = .any
        case RawValue(CPU_TYPE_VAX): self = .vax
        case RawValue(CPU_TYPE_MC680x0): self = .mc680x0
        case RawValue(CPU_TYPE_X86): self = .x86
        case RawValue(CPU_TYPE_I386): self = .i386
        case RawValue(CPU_TYPE_X86_64): self = .x86_64
        case RawValue(CPU_TYPE_MC98000): self = .mc98000
        case RawValue(CPU_TYPE_HPPA): self = .hppa
        case RawValue(CPU_TYPE_ARM): self = .arm
        case RawValue(CPU_TYPE_ARM64): self = .arm64
        case RawValue(CPU_TYPE_ARM64_32): self = .arm64_32
        case RawValue(CPU_TYPE_MC88000): self = .mc88000
        case RawValue(CPU_TYPE_SPARC): self = .sparc
        case RawValue(CPU_TYPE_I860): self = .i860
        case RawValue(CPU_TYPE_POWERPC): self = .powerpc
        case RawValue(CPU_TYPE_POWERPC64): self = .powerpc64
        default:
            return nil
        }
    }

    public var rawValue: cpu_type_t {
        switch self {
        case .any: RawValue(CPU_TYPE_ANY)
        case .vax: RawValue(CPU_TYPE_VAX)
        case .mc680x0: RawValue(CPU_TYPE_MC680x0)
        case .x86: RawValue(CPU_TYPE_X86)
        case .i386: RawValue(CPU_TYPE_I386)
        case .x86_64: RawValue(CPU_TYPE_X86_64)
        case .mc98000: RawValue(CPU_TYPE_MC98000)
        case .hppa: RawValue(CPU_TYPE_HPPA)
        case .arm: RawValue(CPU_TYPE_ARM)
        case .arm64: RawValue(CPU_TYPE_ARM64)
        case .arm64_32: RawValue(CPU_TYPE_ARM64_32)
        case .mc88000: RawValue(CPU_TYPE_MC88000)
        case .sparc: RawValue(CPU_TYPE_SPARC)
        case .i860: RawValue(CPU_TYPE_I860)
        case .powerpc: RawValue(CPU_TYPE_POWERPC)
        case .powerpc64: RawValue(CPU_TYPE_POWERPC64)
        }
    }
}

extension CPUType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .any: "CPU_TYPE_ANY"
        case .vax: "CPU_TYPE_VAX"
        case .mc680x0: "CPU_TYPE_MC680x0"
        case .x86: "CPU_TYPE_X86"
        case .i386: "CPU_TYPE_I386"
        case .x86_64: "CPU_TYPE_X86_64"
        case .mc98000: "CPU_TYPE_MC98000"
        case .hppa: "CPU_TYPE_HPPA"
        case .arm: "CPU_TYPE_ARM"
        case .arm64: "CPU_TYPE_ARM64"
        case .arm64_32: "CPU_TYPE_ARM64_32"
        case .mc88000: "CPU_TYPE_MC88000"
        case .sparc: "CPU_TYPE_SPARC"
        case .i860: "CPU_TYPE_I860"
        case .powerpc: "CPU_TYPE_POWERPC"
        case .powerpc64: "CPU_TYPE_POWERPC64"
        }
    }
}

extension CPUType {
    public var is64Bit: Bool {
        rawValue & CPU_ARCH_ABI64 != 0
    }

    public var is64BitHardwareWith32BitType: Bool {
        rawValue & CPU_ARCH_ABI64_32 != 0
    }
}

#if canImport(Darwin)
extension CPUType {
    /// CPU type of host pc
    public static var current: CPUType? {
        var type: cpu_type_t = 0
        var size = MemoryLayout<cpu_type_t>.size
        let ret = sysctlbyname("hw.cputype", &type, &size, nil, 0)
        guard ret != -1 else { return nil }

        var is64BitCapable: Int = 0
        sysctlbyname("hw.cpu64bit_capable", &is64BitCapable, &size, nil, 0)
        if is64BitCapable == 1 {
            type |= CPU_ARCH_ABI64
        }

        return .init(rawValue: type)
    }
}
#endif
