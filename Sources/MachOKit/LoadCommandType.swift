//
//  LoadCommandType.swift
//
//
//  Created by p-x9 on 2023/11/28.
//
//

import Foundation
import MachO

public enum LoadCommandType: Int32 {
    case segment // LC_SEGMENT
    case symtab // LC_SYMTAB
    case symseg // LC_SYMSEG
    case thread // LC_THREAD
    case unixthread // LC_UNIXTHREAD
    case loadfvmlib // LC_LOADFVMLIB
    case idfvmlib // LC_IDFVMLIB
    case ident // LC_IDENT
    case fvmfile // LC_FVMFILE
    case prepage // LC_PREPAGE
    case dysymtab // LC_DYSYMTAB
    case loadDylib // LC_LOAD_DYLIB
    case idDylib // LC_ID_DYLIB
    case loadDylinker // LC_LOAD_DYLINKER
    case idDylinker // LC_ID_DYLINKER
    case preboundDylib // LC_PREBOUND_DYLIB
    case routines // LC_ROUTINES
    case subFramework // LC_SUB_FRAMEWORK
    case subUmbrella // LC_SUB_UMBRELLA
    case subClient // LC_SUB_CLIENT
    case subLibrary // LC_SUB_LIBRARY
    case twolevelHints // LC_TWOLEVEL_HINTS
    case prebindCksum // LC_PREBIND_CKSUM
    case loadWeakDylib // LC_LOAD_WEAK_DYLIB
    case segment64 // LC_SEGMENT_64
    case routines64 // LC_ROUTINES_64
    case uuid // LC_UUID
    case rpath // LC_RPATH
    case codeSignature // LC_CODE_SIGNATURE
    case segmentSplitInfo // LC_SEGMENT_SPLIT_INFO
    case reexportDylib // LC_REEXPORT_DYLIB
    case lazyLoadDylib // LC_LAZY_LOAD_DYLIB
    case encryptionInfo // LC_ENCRYPTION_INFO
    case dyldInfo // LC_DYLD_INFO
    case dyldInfoOnly // LC_DYLD_INFO_ONLY
    case loadUpwardDylib // LC_LOAD_UPWARD_DYLIB
    case versionMinMacosx // LC_VERSION_MIN_MACOSX
    case versionMinIphoneos // LC_VERSION_MIN_IPHONEOS
    case functionStarts // LC_FUNCTION_STARTS
    case dyldEnvironment // LC_DYLD_ENVIRONMENT
    case main // LC_MAIN
    case dataInCode // LC_DATA_IN_CODE
    case sourceVersion // LC_SOURCE_VERSION
    case dylibCodeSignDrs // LC_DYLIB_CODE_SIGN_DRS
    case encryptionInfo64 // LC_ENCRYPTION_INFO_64
    case linkerOption // LC_LINKER_OPTION
    case linkerOptimizationHint // LC_LINKER_OPTIMIZATION_HINT
    case versionMinTvos // LC_VERSION_MIN_TVOS
    case versionMinWatchos // LC_VERSION_MIN_WATCHOS
    case note // LC_NOTE
    case buildVersion // LC_BUILD_VERSION
    case dyldExportsTrie // LC_DYLD_EXPORTS_TRIE
    case dyldChainedFixups // LC_DYLD_CHAINED_FIXUPS
    case filesetEntry // LC_FILESET_ENTRY
    case atomInfo // LC_ATOM_INFO
}


extension LoadCommandType {
    public init?(rawValue: Int32) {
        switch rawValue {
        case LC_SEGMENT: self = .segment
        case LC_SYMTAB: self = .symtab
        case LC_SYMSEG: self = .symseg
        case LC_THREAD: self = .thread
        case LC_UNIXTHREAD: self = .unixthread
        case LC_LOADFVMLIB: self = .loadfvmlib
        case LC_IDFVMLIB: self = .idfvmlib
        case LC_IDENT: self = .ident
        case LC_FVMFILE: self = .fvmfile
        case LC_PREPAGE: self = .prepage
        case LC_DYSYMTAB: self = .dysymtab
        case LC_LOAD_DYLIB: self = .loadDylib
        case LC_ID_DYLIB: self = .idDylib
        case LC_LOAD_DYLINKER: self = .loadDylinker
        case LC_ID_DYLINKER: self = .idDylinker
        case LC_PREBOUND_DYLIB: self = .preboundDylib
        case LC_ROUTINES: self = .routines
        case LC_SUB_FRAMEWORK: self = .subFramework
        case LC_SUB_UMBRELLA: self = .subUmbrella
        case LC_SUB_CLIENT: self = .subClient
        case LC_SUB_LIBRARY: self = .subLibrary
        case LC_TWOLEVEL_HINTS: self = .twolevelHints
        case LC_PREBIND_CKSUM: self = .prebindCksum
        case Int32(LC_LOAD_WEAK_DYLIB): self = .loadWeakDylib
        case LC_SEGMENT_64: self = .segment64
        case LC_ROUTINES_64: self = .routines64
        case LC_UUID: self = .uuid
        case Int32(LC_RPATH): self = .rpath
        case LC_CODE_SIGNATURE: self = .codeSignature
        case LC_SEGMENT_SPLIT_INFO: self = .segmentSplitInfo
        case Int32(LC_REEXPORT_DYLIB): self = .reexportDylib
        case LC_LAZY_LOAD_DYLIB: self = .lazyLoadDylib
        case LC_ENCRYPTION_INFO: self = .encryptionInfo
        case LC_DYLD_INFO: self = .dyldInfo
        case Int32(LC_DYLD_INFO_ONLY): self = .dyldInfoOnly
        case Int32(LC_LOAD_UPWARD_DYLIB): self = .loadUpwardDylib
        case LC_VERSION_MIN_MACOSX: self = .versionMinMacosx
        case LC_VERSION_MIN_IPHONEOS: self = .versionMinIphoneos
        case LC_FUNCTION_STARTS: self = .functionStarts
        case LC_DYLD_ENVIRONMENT: self = .dyldEnvironment
        case Int32(LC_MAIN): self = .main
        case LC_DATA_IN_CODE: self = .dataInCode
        case LC_SOURCE_VERSION: self = .sourceVersion
        case LC_DYLIB_CODE_SIGN_DRS: self = .dylibCodeSignDrs
        case LC_ENCRYPTION_INFO_64: self = .encryptionInfo64
        case LC_LINKER_OPTION: self = .linkerOption
        case LC_LINKER_OPTIMIZATION_HINT: self = .linkerOptimizationHint
        case LC_VERSION_MIN_TVOS: self = .versionMinTvos
        case LC_VERSION_MIN_WATCHOS: self = .versionMinWatchos
        case LC_NOTE: self = .note
        case LC_BUILD_VERSION: self = .buildVersion
        case Int32(LC_DYLD_EXPORTS_TRIE): self = .dyldExportsTrie
        case Int32(LC_DYLD_CHAINED_FIXUPS): self = .dyldChainedFixups
        case Int32(LC_FILESET_ENTRY): self = .filesetEntry
        case LC_ATOM_INFO: self = .atomInfo
        default: return nil
        }
    }
}

extension LoadCommandType {
    public var rawValue: Int32 {
        switch self {
        case .segment: LC_SEGMENT
        case .symtab: LC_SYMTAB
        case .symseg: LC_SYMSEG
        case .thread: LC_THREAD
        case .unixthread: LC_UNIXTHREAD
        case .loadfvmlib: LC_LOADFVMLIB
        case .idfvmlib: LC_IDFVMLIB
        case .ident: LC_IDENT
        case .fvmfile: LC_FVMFILE
        case .prepage: LC_PREPAGE
        case .dysymtab: LC_DYSYMTAB
        case .loadDylib: LC_LOAD_DYLIB
        case .idDylib: LC_ID_DYLIB
        case .loadDylinker: LC_LOAD_DYLINKER
        case .idDylinker: LC_ID_DYLINKER
        case .preboundDylib: LC_PREBOUND_DYLIB
        case .routines: LC_ROUTINES
        case .subFramework: LC_SUB_FRAMEWORK
        case .subUmbrella: LC_SUB_UMBRELLA
        case .subClient: LC_SUB_CLIENT
        case .subLibrary: LC_SUB_LIBRARY
        case .twolevelHints: LC_TWOLEVEL_HINTS
        case .prebindCksum: LC_PREBIND_CKSUM
        case .loadWeakDylib: Int32(LC_LOAD_WEAK_DYLIB)
        case .segment64: LC_SEGMENT_64
        case .routines64: LC_ROUTINES_64
        case .uuid: LC_UUID
        case .rpath: Int32(LC_RPATH)
        case .codeSignature: LC_CODE_SIGNATURE
        case .segmentSplitInfo: LC_SEGMENT_SPLIT_INFO
        case .reexportDylib: Int32(LC_REEXPORT_DYLIB)
        case .lazyLoadDylib: LC_LAZY_LOAD_DYLIB
        case .encryptionInfo: LC_ENCRYPTION_INFO
        case .dyldInfo: LC_DYLD_INFO
        case .dyldInfoOnly: Int32(LC_DYLD_INFO_ONLY)
        case .loadUpwardDylib: Int32(LC_LOAD_UPWARD_DYLIB)
        case .versionMinMacosx: LC_VERSION_MIN_MACOSX
        case .versionMinIphoneos: LC_VERSION_MIN_IPHONEOS
        case .functionStarts: LC_FUNCTION_STARTS
        case .dyldEnvironment: LC_DYLD_ENVIRONMENT
        case .main: Int32(LC_MAIN)
        case .dataInCode: LC_DATA_IN_CODE
        case .sourceVersion: LC_SOURCE_VERSION
        case .dylibCodeSignDrs: LC_DYLIB_CODE_SIGN_DRS
        case .encryptionInfo64: LC_ENCRYPTION_INFO_64
        case .linkerOption: LC_LINKER_OPTION
        case .linkerOptimizationHint: LC_LINKER_OPTIMIZATION_HINT
        case .versionMinTvos: LC_VERSION_MIN_TVOS
        case .versionMinWatchos: LC_VERSION_MIN_WATCHOS
        case .note: LC_NOTE
        case .buildVersion: LC_BUILD_VERSION
        case .dyldExportsTrie: Int32(LC_DYLD_EXPORTS_TRIE)
        case .dyldChainedFixups: Int32(LC_DYLD_CHAINED_FIXUPS)
        case .filesetEntry: Int32(LC_FILESET_ENTRY)
        case .atomInfo: LC_ATOM_INFO
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
