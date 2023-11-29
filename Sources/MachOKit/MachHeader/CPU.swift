//
//  CPU.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public enum CPU {
    case any(CPUAnySubType?)
    case vax(CPUVAXSubType?)
    case mc680x0(CPUMC680x0SubType?)
    case x86(CPUX86SubType?)
    case i386(CPUI386SubType?)
    case x86_64(CPUX86SubType?)
    case mc98000(CPUMC98000SubType?)
    case hppa(CPUHPPASubType?)
    case arm(CPUARMSubType?)
    case arm64(CPUARM64SubType?)
    case arm64_32(CPUARM64_32SubType?)
    case mc88000(CPUMC88000SubType?)
    case sparc(CPUSPARCSubType?)
    case i860(CPUI860SubType?)
    case powerpc(CPUPowerPCSubType?)
    case powerpc64(CPUPowerPCSubType?)
}

extension CPU {
    public init(
        type: CPUType,
        subtype: cpu_subtype_t
    ) {
        switch type {
        case .any:
            self = .any(.init(rawValue: subtype))
        case .vax:
            self = .vax(.init(rawValue: subtype))
        case .mc680x0:
            self = .mc680x0(.init(rawValue: subtype))
        case .x86:
            self = .x86(.init(rawValue: subtype))
        case .i386:
            self = .i386(.init(rawValue: subtype))
        case .x86_64:
            self = .x86_64(.init(rawValue: subtype))
        case .mc98000:
            self = .mc98000(.init(rawValue: subtype))
        case .hppa:
            self = .hppa(.init(rawValue: subtype))
        case .arm:
            self = .arm(.init(rawValue: subtype))
        case .arm64:
            self = .arm64(.init(rawValue: subtype))
        case .arm64_32:
            self = .arm64_32(.init(rawValue: subtype))
        case .mc88000:
            self = .mc88000(.init(rawValue: subtype))
        case .sparc:
            self = .sparc(.init(rawValue: subtype))
        case .i860:
            self = .i860(.init(rawValue: subtype))
        case .powerpc:
            self = .powerpc(.init(rawValue: subtype))
        case .powerpc64:
            self = .powerpc64(.init(rawValue: subtype))
        }
    }
}

extension CPU {
    public var type: CPUType {
        switch self {
        case .any: .any
        case .vax: .vax
        case .mc680x0: .mc680x0
        case .x86: .x86
        case .i386: .i386
        case .x86_64: .x86_64
        case .mc98000: .mc98000
        case .hppa: .hppa
        case .arm: .arm
        case .arm64: .arm64
        case .arm64_32: .arm64_32
        case .mc88000: .mc88000
        case .sparc: .sparc
        case .i860: .i860
        case .powerpc: .powerpc
        case .powerpc64: .powerpc64
        }
    }
}

extension CPU: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .any(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .vax(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .mc680x0(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .x86(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .i386(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .x86_64(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .mc98000(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .hppa(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .arm(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .arm64(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .arm64_32(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .mc88000(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .sparc(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .i860(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .powerpc(info):
            "\(type)(\(info?.description ?? "unknown"))"
        case let .powerpc64(info):
            "\(type)(\(info?.description ?? "unknown"))"
        }
    }
}
