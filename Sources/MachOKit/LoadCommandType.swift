//
//  LoadCommandType.swift
//
//
//  Created by p-x9 on 2023/11/28.
//
//

import Foundation
import MachO

public enum LoadCommandType {
    /// LC_SEGMENT
    case segment
    /// LC_SYMTAB
    case symtab
    /// LC_SYMSEG
    case symseg
    /// LC_THREAD
    case thread
    /// LC_UNIXTHREAD
    case unixthread
    /// LC_LOADFVMLIB
    case loadfvmlib
    /// LC_IDFVMLIB
    case idfvmlib
    /// LC_IDENT
    case ident
    /// LC_FVMFILE
    case fvmfile
    /// LC_PREPAGE
    case prepage
    /// LC_DYSYMTAB
    case dysymtab
    /// LC_LOAD_DYLIB
    case loadDylib
    /// LC_ID_DYLIB
    case idDylib
    /// LC_LOAD_DYLINKER
    case loadDylinker
    /// LC_ID_DYLINKER
    case idDylinker
    /// LC_PREBOUND_DYLIB
    case preboundDylib
    /// LC_ROUTINES
    case routines
    /// LC_SUB_FRAMEWORK
    case subFramework
    /// LC_SUB_UMBRELLA
    case subUmbrella
    /// LC_SUB_CLIENT
    case subClient
    /// LC_SUB_LIBRARY
    case subLibrary
    /// LC_TWOLEVEL_HINTS
    case twolevelHints
    /// LC_PREBIND_CKSUM
    case prebindCksum
    /// LC_LOAD_WEAK_DYLIB
    case loadWeakDylib
    /// LC_SEGMENT_64
    case segment64
    /// LC_ROUTINES_64
    case routines64
    /// LC_UUID
    case uuid
    /// LC_RPATH
    case rpath
    /// LC_CODE_SIGNATURE
    case codeSignature
    /// LC_SEGMENT_SPLIT_INFO
    case segmentSplitInfo
    /// LC_REEXPORT_DYLIB
    case reexportDylib
    /// LC_LAZY_LOAD_DYLIB
    case lazyLoadDylib
    /// LC_ENCRYPTION_INFO
    case encryptionInfo
    /// LC_DYLD_INFO
    case dyldInfo
    /// LC_DYLD_INFO_ONLY
    case dyldInfoOnly
    /// LC_LOAD_UPWARD_DYLIB
    case loadUpwardDylib
    /// LC_VERSION_MIN_MACOSX
    case versionMinMacosx
    /// LC_VERSION_MIN_IPHONEOS
    case versionMinIphoneos
    /// LC_FUNCTION_STARTS
    case functionStarts
    /// LC_DYLD_ENVIRONMENT
    case dyldEnvironment
    /// LC_MAIN
    case main
    /// LC_DATA_IN_CODE
    case dataInCode
    /// LC_SOURCE_VERSION
    case sourceVersion
    /// LC_DYLIB_CODE_SIGN_DRS
    case dylibCodeSignDrs
    /// LC_ENCRYPTION_INFO_64
    case encryptionInfo64
    /// LC_LINKER_OPTION
    case linkerOption
    /// LC_LINKER_OPTIMIZATION_HINT
    case linkerOptimizationHint
    /// LC_VERSION_MIN_TVOS
    case versionMinTvos
    /// LC_VERSION_MIN_WATCHOS
    case versionMinWatchos
    /// LC_NOTE
    case note
    /// LC_BUILD_VERSION
    case buildVersion
    /// LC_DYLD_EXPORTS_TRIE
    case dyldExportsTrie
    /// LC_DYLD_CHAINED_FIXUPS
    case dyldChainedFixups
    /// LC_FILESET_ENTRY
    case filesetEntry
    /// LC_ATOM_INFO
    case atomInfo
}

extension LoadCommandType: RawRepresentable {
    public init?(rawValue: UInt32) {
        switch rawValue {
        case 0x1 /* LC_SEGMENT */: self = .segment
        case 0x2 /* LC_SYMTAB */: self = .symtab
        case 0x3 /* LC_SYMSEG */: self = .symseg
        case 0x4 /* LC_THREAD */: self = .thread
        case 0x5 /* LC_UNIXTHREAD */: self = .unixthread
        case 0x6 /* LC_LOADFVMLIB */: self = .loadfvmlib
        case 0x7 /* LC_IDFVMLIB */: self = .idfvmlib
        case 0x8 /* LC_IDENT */: self = .ident
        case 0x9 /* LC_FVMFILE */: self = .fvmfile
        case 0xa /* LC_PREPAGE */: self = .prepage
        case 0xb /* LC_DYSYMTAB */: self = .dysymtab
        case 0xc /* LC_LOAD_DYLIB */: self = .loadDylib
        case 0xd /* LC_ID_DYLIB */: self = .idDylib
        case 0xe /* LC_LOAD_DYLINKER */: self = .loadDylinker
        case 0xf /* LC_ID_DYLINKER */: self = .idDylinker
        case 0x10 /* LC_PREBOUND_DYLIB */: self = .preboundDylib
        case 0x11 /* LC_ROUTINES */: self = .routines
        case 0x12 /* LC_SUB_FRAMEWORK */: self = .subFramework
        case 0x13 /* LC_SUB_UMBRELLA */: self = .subUmbrella
        case 0x14 /* LC_SUB_CLIENT */: self = .subClient
        case 0x15 /* LC_SUB_LIBRARY */: self = .subLibrary
        case 0x16 /* LC_TWOLEVEL_HINTS */: self = .twolevelHints
        case 0x17 /* LC_PREBIND_CKSUM */: self = .prebindCksum
        case 0x18 | 0x80000000 /* LC_LOAD_WEAK_DYLIB */: self = .loadWeakDylib
        case 0x19 /* LC_SEGMENT_64 */: self = .segment64
        case 0x1a /* LC_ROUTINES_64 */: self = .routines64
        case 0x1b /* LC_UUID */: self = .uuid
        case 0x1c | 0x80000000 /* LC_RPATH */: self = .rpath
        case 0x1d /* LC_CODE_SIGNATURE */: self = .codeSignature
        case 0x1e /* LC_SEGMENT_SPLIT_INFO */: self = .segmentSplitInfo
        case 0x1f | 0x80000000 /* LC_REEXPORT_DYLIB */: self = .reexportDylib
        case 0x20 /* LC_LAZY_LOAD_DYLIB */: self = .lazyLoadDylib
        case 0x21 /* LC_ENCRYPTION_INFO */: self = .encryptionInfo
        case 0x22 /* LC_DYLD_INFO */: self = .dyldInfo
        case 0x22 | 0x80000000 /* LC_DYLD_INFO_ONLY */: self = .dyldInfoOnly
        case 0x23 | 0x80000000 /* LC_LOAD_UPWARD_DYLIB */: self = .loadUpwardDylib
        case 0x24 /* LC_VERSION_MIN_MACOSX */: self = .versionMinMacosx
        case 0x25 /* LC_VERSION_MIN_IPHONEOS */: self = .versionMinIphoneos
        case 0x26 /* LC_FUNCTION_STARTS */: self = .functionStarts
        case 0x27 /* LC_DYLD_ENVIRONMENT */: self = .dyldEnvironment
        case 0x28 | 0x80000000 /* LC_MAIN */: self = .main
        case 0x29 /* LC_DATA_IN_CODE */: self = .dataInCode
        case 0x2A /* LC_SOURCE_VERSION */: self = .sourceVersion
        case 0x2B /* LC_DYLIB_CODE_SIGN_DRS */: self = .dylibCodeSignDrs
        case 0x2C /* LC_ENCRYPTION_INFO_64 */: self = .encryptionInfo64
        case 0x2D /* LC_LINKER_OPTION */: self = .linkerOption
        case 0x2E /* LC_LINKER_OPTIMIZATION_HINT */: self = .linkerOptimizationHint
        case 0x2F /* LC_VERSION_MIN_TVOS */: self = .versionMinTvos
        case 0x30 /* LC_VERSION_MIN_WATCHOS */: self = .versionMinWatchos
        case 0x31 /* LC_NOTE */: self = .note
        case 0x32 /* LC_BUILD_VERSION */: self = .buildVersion
        case 0x33 | 0x80000000 /* LC_DYLD_EXPORTS_TRIE */: self = .dyldExportsTrie
        case 0x34 | 0x80000000 /* LC_DYLD_CHAINED_FIXUPS */: self = .dyldChainedFixups
        case 0x35 | 0x80000000 /* LC_FILESET_ENTRY */: self = .filesetEntry
        case 0x36 /* LC_ATOM_INFO */: self = .atomInfo
        default: return nil
        }
    }
}

extension LoadCommandType {
    public var rawValue: UInt32 {
        switch self {
        case .segment: UInt32(LC_SEGMENT)
        case .symtab: UInt32(LC_SYMTAB)
        case .symseg: UInt32(LC_SYMSEG)
        case .thread: UInt32(LC_THREAD)
        case .unixthread: UInt32(LC_UNIXTHREAD)
        case .loadfvmlib: UInt32(LC_LOADFVMLIB)
        case .idfvmlib: UInt32(LC_IDFVMLIB)
        case .ident: UInt32(LC_IDENT)
        case .fvmfile: UInt32(LC_FVMFILE)
        case .prepage: UInt32(LC_PREPAGE)
        case .dysymtab: UInt32(LC_DYSYMTAB)
        case .loadDylib: UInt32(LC_LOAD_DYLIB)
        case .idDylib: UInt32(LC_ID_DYLIB)
        case .loadDylinker: UInt32(LC_LOAD_DYLINKER)
        case .idDylinker: UInt32(LC_ID_DYLINKER)
        case .preboundDylib: UInt32(LC_PREBOUND_DYLIB)
        case .routines: UInt32(LC_ROUTINES)
        case .subFramework: UInt32(LC_SUB_FRAMEWORK)
        case .subUmbrella: UInt32(LC_SUB_UMBRELLA)
        case .subClient: UInt32(LC_SUB_CLIENT)
        case .subLibrary: UInt32(LC_SUB_LIBRARY)
        case .twolevelHints: UInt32(LC_TWOLEVEL_HINTS)
        case .prebindCksum: UInt32(LC_PREBIND_CKSUM)
        case .loadWeakDylib: UInt32(LC_LOAD_WEAK_DYLIB)
        case .segment64: UInt32(LC_SEGMENT_64)
        case .routines64: UInt32(LC_ROUTINES_64)
        case .uuid: UInt32(LC_UUID)
        case .rpath: UInt32(LC_RPATH)
        case .codeSignature: UInt32(LC_CODE_SIGNATURE)
        case .segmentSplitInfo: UInt32(LC_SEGMENT_SPLIT_INFO)
        case .reexportDylib: UInt32(LC_REEXPORT_DYLIB)
        case .lazyLoadDylib: UInt32(LC_LAZY_LOAD_DYLIB)
        case .encryptionInfo: UInt32(LC_ENCRYPTION_INFO)
        case .dyldInfo: UInt32(LC_DYLD_INFO)
        case .dyldInfoOnly: UInt32(LC_DYLD_INFO_ONLY)
        case .loadUpwardDylib: UInt32(LC_LOAD_UPWARD_DYLIB)
        case .versionMinMacosx: UInt32(LC_VERSION_MIN_MACOSX)
        case .versionMinIphoneos: UInt32(LC_VERSION_MIN_IPHONEOS)
        case .functionStarts: UInt32(LC_FUNCTION_STARTS)
        case .dyldEnvironment: UInt32(LC_DYLD_ENVIRONMENT)
        case .main: UInt32(LC_MAIN)
        case .dataInCode: UInt32(LC_DATA_IN_CODE)
        case .sourceVersion: UInt32(LC_SOURCE_VERSION)
        case .dylibCodeSignDrs: UInt32(LC_DYLIB_CODE_SIGN_DRS)
        case .encryptionInfo64: UInt32(LC_ENCRYPTION_INFO_64)
        case .linkerOption: UInt32(LC_LINKER_OPTION)
        case .linkerOptimizationHint: UInt32(LC_LINKER_OPTIMIZATION_HINT)
        case .versionMinTvos: UInt32(LC_VERSION_MIN_TVOS)
        case .versionMinWatchos: UInt32(LC_VERSION_MIN_WATCHOS)
        case .note: UInt32(LC_NOTE)
        case .buildVersion: UInt32(LC_BUILD_VERSION)
        case .dyldExportsTrie: UInt32(LC_DYLD_EXPORTS_TRIE)
        case .dyldChainedFixups: UInt32(LC_DYLD_CHAINED_FIXUPS)
        case .filesetEntry: UInt32(LC_FILESET_ENTRY)
        case .atomInfo: UInt32(LC_ATOM_INFO)
        }
    }
}

extension LoadCommandType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .segment: "LC_SEGMENT"
        case .symtab: "LC_SYMTAB"
        case .symseg: "LC_SYMSEG"
        case .thread: "LC_THREAD"
        case .unixthread: "LC_UNIXTHREAD"
        case .loadfvmlib: "LC_LOADFVMLIB"
        case .idfvmlib: "LC_IDFVMLIB"
        case .ident: "LC_IDENT"
        case .fvmfile: "LC_FVMFILE"
        case .prepage: "LC_PREPAGE"
        case .dysymtab: "LC_DYSYMTAB"
        case .loadDylib: "LC_LOAD_DYLIB"
        case .idDylib: "LC_ID_DYLIB"
        case .loadDylinker: "LC_LOAD_DYLINKER"
        case .idDylinker: "LC_ID_DYLINKER"
        case .preboundDylib: "LC_PREBOUND_DYLIB"
        case .routines: "LC_ROUTINES"
        case .subFramework: "LC_SUB_FRAMEWORK"
        case .subUmbrella: "LC_SUB_UMBRELLA"
        case .subClient: "LC_SUB_CLIENT"
        case .subLibrary: "LC_SUB_LIBRARY"
        case .twolevelHints: "LC_TWOLEVEL_HINTS"
        case .prebindCksum: "LC_PREBIND_CKSUM"
        case .loadWeakDylib: "LC_LOAD_WEAK_DYLIB"
        case .segment64: "LC_SEGMENT_64"
        case .routines64: "LC_ROUTINES_64"
        case .uuid: "LC_UUID"
        case .rpath: "LC_RPATH"
        case .codeSignature: "LC_CODE_SIGNATURE"
        case .segmentSplitInfo: "LC_SEGMENT_SPLIT_INFO"
        case .reexportDylib: "LC_REEXPORT_DYLIB"
        case .lazyLoadDylib: "LC_LAZY_LOAD_DYLIB"
        case .encryptionInfo: "LC_ENCRYPTION_INFO"
        case .dyldInfo: "LC_DYLD_INFO"
        case .dyldInfoOnly: "LC_DYLD_INFO_ONLY"
        case .loadUpwardDylib: "LC_LOAD_UPWARD_DYLIB"
        case .versionMinMacosx: "LC_VERSION_MIN_MACOSX"
        case .versionMinIphoneos: "LC_VERSION_MIN_IPHONEOS"
        case .functionStarts: "LC_FUNCTION_STARTS"
        case .dyldEnvironment: "LC_DYLD_ENVIRONMENT"
        case .main: "LC_MAIN"
        case .dataInCode: "LC_DATA_IN_CODE"
        case .sourceVersion: "LC_SOURCE_VERSION"
        case .dylibCodeSignDrs: "LC_DYLIB_CODE_SIGN_DRS"
        case .encryptionInfo64: "LC_ENCRYPTION_INFO_64"
        case .linkerOption: "LC_LINKER_OPTION"
        case .linkerOptimizationHint: "LC_LINKER_OPTIMIZATION_HINT"
        case .versionMinTvos: "LC_VERSION_MIN_TVOS"
        case .versionMinWatchos: "LC_VERSION_MIN_WATCHOS"
        case .note: "LC_NOTE"
        case .buildVersion: "LC_BUILD_VERSION"
        case .dyldExportsTrie: "LC_DYLD_EXPORTS_TRIE"
        case .dyldChainedFixups: "LC_DYLD_CHAINED_FIXUPS"
        case .filesetEntry: "LC_FILESET_ENTRY"
        case .atomInfo: "LC_ATOM_INFO"
        }
    }
}
