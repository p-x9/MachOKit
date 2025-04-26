//
//  LoadCommandType.swift
//
//
//  Created by p-x9 on 2023/11/28.
//
//

import Foundation

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
    /// LC_FUNCTION_VARIANTS
    case functionVariants
    /// LC_FUNCTION_VARIANT_FIXUPS
    case functionVariantFixups
    /// LC_TARGET_TRIPLE
    case targetTriple
}

extension LoadCommandType: RawRepresentable {
    public init?(rawValue: UInt32) {
        switch rawValue {
        case UInt32(LC_SEGMENT): self = .segment
        case UInt32(LC_SYMTAB): self = .symtab
        case UInt32(LC_SYMSEG): self = .symseg
        case UInt32(LC_THREAD): self = .thread
        case UInt32(LC_UNIXTHREAD): self = .unixthread
        case UInt32(LC_LOADFVMLIB): self = .loadfvmlib
        case UInt32(LC_IDFVMLIB): self = .idfvmlib
        case UInt32(LC_IDENT): self = .ident
        case UInt32(LC_FVMFILE): self = .fvmfile
        case UInt32(LC_PREPAGE): self = .prepage
        case UInt32(LC_DYSYMTAB): self = .dysymtab
        case UInt32(LC_LOAD_DYLIB): self = .loadDylib
        case UInt32(LC_ID_DYLIB): self = .idDylib
        case UInt32(LC_LOAD_DYLINKER): self = .loadDylinker
        case UInt32(LC_ID_DYLINKER): self = .idDylinker
        case UInt32(LC_PREBOUND_DYLIB): self = .preboundDylib
        case UInt32(LC_ROUTINES): self = .routines
        case UInt32(LC_SUB_FRAMEWORK): self = .subFramework
        case UInt32(LC_SUB_UMBRELLA): self = .subUmbrella
        case UInt32(LC_SUB_CLIENT): self = .subClient
        case UInt32(LC_SUB_LIBRARY): self = .subLibrary
        case UInt32(LC_TWOLEVEL_HINTS): self = .twolevelHints
        case UInt32(LC_PREBIND_CKSUM): self = .prebindCksum
        case UInt32(LC_LOAD_WEAK_DYLIB): self = .loadWeakDylib
        case UInt32(LC_SEGMENT_64): self = .segment64
        case UInt32(LC_ROUTINES_64): self = .routines64
        case UInt32(LC_UUID): self = .uuid
        case UInt32(LC_RPATH): self = .rpath
        case UInt32(LC_CODE_SIGNATURE): self = .codeSignature
        case UInt32(LC_SEGMENT_SPLIT_INFO): self = .segmentSplitInfo
        case UInt32(LC_REEXPORT_DYLIB): self = .reexportDylib
        case UInt32(LC_LAZY_LOAD_DYLIB): self = .lazyLoadDylib
        case UInt32(LC_ENCRYPTION_INFO): self = .encryptionInfo
        case UInt32(LC_DYLD_INFO): self = .dyldInfo
        case UInt32(LC_DYLD_INFO_ONLY): self = .dyldInfoOnly
        case UInt32(LC_LOAD_UPWARD_DYLIB): self = .loadUpwardDylib
        case UInt32(LC_VERSION_MIN_MACOSX): self = .versionMinMacosx
        case UInt32(LC_VERSION_MIN_IPHONEOS): self = .versionMinIphoneos
        case UInt32(LC_FUNCTION_STARTS): self = .functionStarts
        case UInt32(LC_DYLD_ENVIRONMENT): self = .dyldEnvironment
        case UInt32(LC_MAIN): self = .main
        case UInt32(LC_DATA_IN_CODE): self = .dataInCode
        case UInt32(LC_SOURCE_VERSION): self = .sourceVersion
        case UInt32(LC_DYLIB_CODE_SIGN_DRS): self = .dylibCodeSignDrs
        case UInt32(LC_ENCRYPTION_INFO_64): self = .encryptionInfo64
        case UInt32(LC_LINKER_OPTION): self = .linkerOption
        case UInt32(LC_LINKER_OPTIMIZATION_HINT): self = .linkerOptimizationHint
        case UInt32(LC_VERSION_MIN_TVOS): self = .versionMinTvos
        case UInt32(LC_VERSION_MIN_WATCHOS): self = .versionMinWatchos
        case UInt32(LC_NOTE): self = .note
        case UInt32(LC_BUILD_VERSION): self = .buildVersion
        case UInt32(LC_DYLD_EXPORTS_TRIE): self = .dyldExportsTrie
        case UInt32(LC_DYLD_CHAINED_FIXUPS): self = .dyldChainedFixups
        case UInt32(LC_FILESET_ENTRY): self = .filesetEntry
        case UInt32(LC_ATOM_INFO): self = .atomInfo
        case UInt32(LC_FUNCTION_VARIANTS): self = .functionVariants
        case UInt32(LC_FUNCTION_VARIANT_FIXUPS): self = .functionVariantFixups
        case UInt32(LC_TARGET_TRIPLE): self = .targetTriple
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
        case .functionVariants: UInt32(LC_FUNCTION_VARIANTS)
        case .functionVariantFixups: UInt32(LC_FUNCTION_VARIANT_FIXUPS)
        case .targetTriple: UInt32(LC_TARGET_TRIPLE)
        }
    }
}

extension LoadCommandType: CustomStringConvertible {
    public var description: String {
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
        case .functionVariants: "LC_FUNCTION_VARIANTS"
        case .functionVariantFixups: "LC_FUNCTION_VARIANT_FIXUPS"
        case .targetTriple: "LC_TARGET_TRIPLE"
        }
    }
}
