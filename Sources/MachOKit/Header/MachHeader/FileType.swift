//
//  FileType.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public enum FileType: Sendable {
    /// MH_OBJECT
    case object
    /// MH_EXECUTE
    case execute
    /// MH_FVMLIB
    case fvmlib
    /// MH_CORE
    case core
    /// MH_PRELOAD
    case preload
    /// MH_DYLIB
    case dylib
    /// MH_DYLINKER
    case dylinker
    /// MH_BUNDLE
    case bundle
    /// MH_DYLIB_STUB
    case dylibStub
    /// MH_DSYM
    case dsym
    /// MH_KEXT_BUNDLE
    case kextBundle
    /// MH_FILESET
    case fileset
    /// MH_GPU_EXECUTE
    case gpuExecute
    /// MH_GPU_DYLIB
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

extension FileType: CustomStringConvertible {
    public var description: String {
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
