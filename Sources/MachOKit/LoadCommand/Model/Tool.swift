//
//  Tool.swift
//  
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public enum Tool {
    case clang
    case swift
    case ld
    case lld

    /* values for gpu tools (1024 to 1048) */
    case metal
    case airLld
    case airNt
    case airNtPlugin
    case airPack
    case gpuArchiver
    case metalFramework
}

extension Tool: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: Int32) {
        switch rawValue {
        case TOOL_CLANG: self = .clang
        case TOOL_SWIFT: self = .swift
        case TOOL_LD: self = .ld
        case TOOL_LLD: self = .lld
        case TOOL_METAL: self = .metal
        case TOOL_AIRLLD: self = .airLld
        case TOOL_AIRNT: self = .airNt
        case TOOL_AIRNT_PLUGIN: self = .airNtPlugin
        case TOOL_AIRPACK: self = .airPack
        case TOOL_GPUARCHIVER: self = .gpuArchiver
        case TOOL_METAL_FRAMEWORK: self = .metalFramework
        default: return nil
        }
    }

    public var rawValue: Int32 {
        switch self {
        case .clang: TOOL_CLANG
        case .swift: TOOL_SWIFT
        case .ld: TOOL_LD
        case .lld: TOOL_LLD
        case .metal: TOOL_METAL
        case .airLld: TOOL_AIRLLD
        case .airNt: TOOL_AIRNT
        case .airNtPlugin: TOOL_AIRNT_PLUGIN
        case .airPack: TOOL_AIRPACK
        case .gpuArchiver: TOOL_GPUARCHIVER
        case .metalFramework: TOOL_METAL_FRAMEWORK
        }
    }
}

extension Tool: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .clang: "TOOL_CLANG"
        case .swift: "TOOL_SWIFT"
        case .ld: "TOOL_LD"
        case .lld: "TOOL_LLD"
        case .metal: "TOOL_METAL"
        case .airLld: "TOOL_AIRLLD"
        case .airNt: "TOOL_AIRNT"
        case .airNtPlugin: "TOOL_AIRNT_PLUGIN"
        case .airPack: "TOOL_AIRPACK"
        case .gpuArchiver: "TOOL_GPUARCHIVER"
        case .metalFramework: "TOOL_METAL_FRAMEWORK"
        }
    }
}
