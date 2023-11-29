//
//  FileType.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public enum FileType {
    case object
    case execute
    case fvmlib
    case core
    case preload
    case dylib
    case dylinker
    case bundle
    case dylibStub
    case dsym
    case kextBundle
    case fileset
    case gpuExecute
    case gpuDylib
}

extension FileType: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: Int32) {
        switch rawValue {
        case MH_OBJECT: self = .object
        case MH_EXECUTE: self = .execute
        case MH_FVMLIB: self = .fvmlib
        case MH_CORE: self = .core
        case MH_PRELOAD: self = .preload
        case MH_DYLIB: self = .dylib
        case MH_DYLINKER: self = .dylinker
        case MH_BUNDLE: self = .bundle
        case MH_DYLIB_STUB: self = .dylibStub
        case MH_DSYM: self = .dsym
        case MH_KEXT_BUNDLE: self = .kextBundle
        case MH_FILESET: self = .fileset
        case MH_GPU_EXECUTE: self = .gpuExecute
        case MH_GPU_DYLIB: self = .gpuDylib
        default: return nil
        }
    }

    public var rawValue: Int32 {
        switch self {
        case .object: MH_OBJECT
        case .execute: MH_EXECUTE
        case .fvmlib: MH_FVMLIB
        case .core: MH_CORE
        case .preload: MH_PRELOAD
        case .dylib: MH_DYLIB
        case .dylinker: MH_DYLINKER
        case .bundle: MH_BUNDLE
        case .dylibStub: MH_DYLIB_STUB
        case .dsym: MH_DSYM
        case .kextBundle: MH_KEXT_BUNDLE
        case .fileset: MH_FILESET
        case .gpuExecute: MH_GPU_EXECUTE
        case .gpuDylib: MH_GPU_DYLIB
        }
    }
}

extension FileType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .object: "MH_OBJECT"
        case .execute: "MH_EXECUTE"
        case .fvmlib: "MH_FVMLIB"
        case .core: "MH_CORE"
        case .preload: "MH_PRELOAD"
        case .dylib: "MH_DYLIB"
        case .dylinker: "MH_DYLINKER"
        case .bundle: "MH_BUNDLE"
        case .dylibStub: "MH_DYLIB_STUB"
        case .dsym: "MH_DSYM"
        case .kextBundle: "MH_KEXT_BUNDLE"
        case .fileset: "MH_FILESET"
        case .gpuExecute: "MH_GPU_EXECUTE"
        case .gpuDylib: "MH_GPU_DYLIB"
        }
    }
}
