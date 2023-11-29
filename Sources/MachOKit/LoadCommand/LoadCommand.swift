//
//  LoadCommand.swift
//
//
//  Created by p-x9 on 2023/11/28.
//
//

import Foundation
import MachO

public enum LoadCommand {
    /// LC_SEGMENT
    case segment(SegmentCommand)
    /// LC_SYMTAB
    case symtab(LoadCommandInfo<symtab_command>)
    /// LC_SYMSEG
    case symseg(LoadCommandInfo<symseg_command>)
    /// LC_THREAD
    case thread(LoadCommandInfo<thread_command>)
    /// LC_UNIXTHREAD
    case unixthread(LoadCommandInfo<thread_command>)
    /// LC_LOADFVMLIB
    case loadfvmlib(LoadCommandInfo<fvmlib_command>)
    /// LC_IDFVMLIB
    case idfvmlib(LoadCommandInfo<fvmlib_command>)
    /// LC_IDENT
    case ident(LoadCommandInfo<ident_command>)
    /// LC_FVMFILE
    case fvmfile(LoadCommandInfo<fvmfile_command>)
    /// LC_PREPAGE
    case prepage(LoadCommandInfo<load_command>) // ????
    /// LC_DYSYMTAB
    case dysymtab(LoadCommandInfo<dysymtab_command>)
    /// LC_LOAD_DYLIB
    case loadDylib(DylibCommand)
    /// LC_ID_DYLIB
    case idDylib(DylibCommand)
    /// LC_LOAD_DYLINKER
    case loadDylinker(LoadCommandInfo<dylinker_command>)
    /// LC_ID_DYLINKER
    case idDylinker(LoadCommandInfo<dylinker_command>)
    /// LC_PREBOUND_DYLIB
    case preboundDylib(LoadCommandInfo<prebound_dylib_command>)
    /// LC_ROUTINES
    case routines(LoadCommandInfo<routines_command>)
    /// LC_SUB_FRAMEWORK
    case subFramework(LoadCommandInfo<sub_framework_command>)
    /// LC_SUB_UMBRELLA
    case subUmbrella(LoadCommandInfo<sub_umbrella_command>)
    /// LC_SUB_CLIENT
    case subClient(LoadCommandInfo<sub_client_command>)
    /// LC_SUB_LIBRARY
    case subLibrary(LoadCommandInfo<sub_library_command>)
    /// LC_TWOLEVEL_HINTS
    case twolevelHints(LoadCommandInfo<twolevel_hints_command>)
    /// LC_PREBIND_CKSUM
    case prebindCksum(LoadCommandInfo<prebind_cksum_command>)
    /// LC_LOAD_WEAK_DYLIB
    case loadWeakDylib(DylibCommand)
    /// LC_SEGMENT_64
    case segment64(SegmentCommand64)
    /// LC_ROUTINES_64
    case routines64(LoadCommandInfo<routines_command_64>)
    /// LC_UUID
    case uuid(LoadCommandInfo<uuid_command>)
    /// LC_RPATH
    case rpath(RpathCommand)
    /// LC_CODE_SIGNATURE
    case codeSignature(LoadCommandInfo<linkedit_data_command>)
    /// LC_SEGMENT_SPLIT_INFO
    case segmentSplitInfo(LoadCommandInfo<linkedit_data_command>)
    /// LC_REEXPORT_DYLIB
    case reexportDylib(DylibCommand)
    /// LC_LAZY_LOAD_DYLIB
    case lazyLoadDylib(DylibCommand)
    /// LC_ENCRYPTION_INFO
    case encryptionInfo(LoadCommandInfo<encryption_info_command>)
    /// LC_DYLD_INFO
    case dyldInfo(LoadCommandInfo<dyld_info_command>)
    /// LC_DYLD_INFO_ONLY
    case dyldInfoOnly(LoadCommandInfo<dyld_info_command>)
    /// LC_LOAD_UPWARD_DYLIB
    case loadUpwardDylib(LoadCommandInfo<load_command>)
    /// LC_VERSION_MIN_MACOSX
    case versionMinMacosx(VersionMinCommand)
    /// LC_VERSION_MIN_IPHONEOS
    case versionMinIphoneos(VersionMinCommand)
    /// LC_FUNCTION_STARTS
    case functionStarts(LoadCommandInfo<linkedit_data_command>)
    /// LC_DYLD_ENVIRONMENT
    case dyldEnvironment(LoadCommandInfo<dylinker_command>)
    /// LC_MAIN
    case main(LoadCommandInfo<entry_point_command>)
    /// LC_DATA_IN_CODE
    case dataInCode(LoadCommandInfo<linkedit_data_command>)
    /// LC_SOURCE_VERSION
    case sourceVersion(LoadCommandInfo<source_version_command>)
    /// LC_DYLIB_CODE_SIGN_DRS
    case dylibCodeSignDrs(LoadCommandInfo<linkedit_data_command>)
    /// LC_ENCRYPTION_INFO_64
    case encryptionInfo64(LoadCommandInfo<encryption_info_command_64>)
    /// LC_LINKER_OPTION
    case linkerOption(LoadCommandInfo<linker_option_command>)
    /// LC_LINKER_OPTIMIZATION_HINT
    case linkerOptimizationHint(LoadCommandInfo<linkedit_data_command>)
    /// LC_VERSION_MIN_TVOS
    case versionMinTvos(VersionMinCommand)
    /// LC_VERSION_MIN_WATCHOS
    case versionMinWatchos(VersionMinCommand)
    /// LC_NOTE
    case note(LoadCommandInfo<note_command>)
    /// LC_BUILD_VERSION
    case buildVersion(BuildVersionCommand)
    /// LC_DYLD_EXPORTS_TRIE
    case dyldExportsTrie(LoadCommandInfo<linkedit_data_command>)
    /// LC_DYLD_CHAINED_FIXUPS
    case dyldChainedFixups(LoadCommandInfo<linkedit_data_command>)
    /// LC_FILESET_ENTRY
    case filesetEntry(LoadCommandInfo<fileset_entry_command>)
    /// LC_ATOM_INFO
    case atomInfo(LoadCommandInfo<linkedit_data_command>)
}

extension LoadCommand {
    public static func convert(
        _ commandPtr: UnsafePointer<load_command>,
        offset: Int
    ) -> LoadCommand? {
        let rawPointer = UnsafeRawPointer(commandPtr)
        let command = commandPtr.pointee
        guard let type = LoadCommandType(rawValue: command.cmd) else {
            return nil
        }
        switch type {
        case .segment:
            return .segment(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .symtab:
            return .symtab(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .symseg:
            return .symseg(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .thread:
            return .thread(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .unixthread:
            return .unixthread(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .loadfvmlib:
            return .loadfvmlib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .idfvmlib:
            return .idfvmlib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .ident:
            return .ident(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .fvmfile:
            return .fvmfile(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .prepage:
            return .prepage(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .dysymtab:
            return .dysymtab(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .loadDylib:
            return .loadDylib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .idDylib:
            return .idDylib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .loadDylinker:
            return .loadDylinker(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .idDylinker:
            return .idDylinker(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .preboundDylib:
            return .preboundDylib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .routines:
            return .routines(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .subFramework:
            return .subFramework(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .subUmbrella:
            return .subUmbrella(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .subClient:
            return .subClient(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .subLibrary:
            return .subLibrary(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .twolevelHints:
            return .twolevelHints(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .prebindCksum:
            return .prebindCksum(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .loadWeakDylib:
            return .loadWeakDylib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .segment64:
            return .segment64(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .routines64:
            return .routines64(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .uuid:
            return .uuid(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .rpath:
            return .rpath(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .codeSignature:
            return .codeSignature(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .segmentSplitInfo:
            return .segmentSplitInfo(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .reexportDylib:
            return .reexportDylib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .lazyLoadDylib:
            return .lazyLoadDylib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .encryptionInfo:
            return .encryptionInfo(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .dyldInfo:
            return .dyldInfo(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .dyldInfoOnly:
            return .dyldInfoOnly(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .loadUpwardDylib:
            return .loadUpwardDylib(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .versionMinMacosx:
            return .versionMinMacosx(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .versionMinIphoneos:
            return .versionMinIphoneos(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .functionStarts:
            return .functionStarts(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .dyldEnvironment:
            return .dyldEnvironment(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .main:
            return .main(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .dataInCode:
            return .dataInCode(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .sourceVersion:
            return .sourceVersion(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .dylibCodeSignDrs:
            return .dylibCodeSignDrs(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .encryptionInfo64:
            return .encryptionInfo64(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .linkerOption:
            return .linkerOption(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .linkerOptimizationHint:
            return .linkerOptimizationHint(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .versionMinTvos:
            return .versionMinTvos(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .versionMinWatchos:
            return .versionMinWatchos(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .note:
            return .note(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .buildVersion:
            return .buildVersion(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .dyldExportsTrie:
            return .dyldExportsTrie(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .dyldChainedFixups:
            return .dyldChainedFixups(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .filesetEntry:
            return .filesetEntry(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .atomInfo:
            return .atomInfo(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        }
    }
}

extension LoadCommand {
    public var type: LoadCommandType {
        switch self {
        case .segment: .segment
        case .symtab: .symtab
        case .symseg: .symseg
        case .thread: .thread
        case .unixthread: .unixthread
        case .loadfvmlib: .loadfvmlib
        case .idfvmlib: .idfvmlib
        case .ident: .ident
        case .fvmfile: .fvmfile
        case .prepage: .prepage
        case .dysymtab: .dysymtab
        case .loadDylib: .loadDylib
        case .idDylib: .idDylib
        case .loadDylinker: .loadDylinker
        case .idDylinker: .idDylinker
        case .preboundDylib: .preboundDylib
        case .routines: .routines
        case .subFramework: .subFramework
        case .subUmbrella: .subUmbrella
        case .subClient: .subClient
        case .subLibrary: .subLibrary
        case .twolevelHints: .twolevelHints
        case .prebindCksum: .prebindCksum
        case .loadWeakDylib: .loadWeakDylib
        case .segment64: .segment64
        case .routines64: .routines64
        case .uuid: .uuid
        case .rpath: .rpath
        case .codeSignature: .codeSignature
        case .segmentSplitInfo: .segmentSplitInfo
        case .reexportDylib: .reexportDylib
        case .lazyLoadDylib: .lazyLoadDylib
        case .encryptionInfo: .encryptionInfo
        case .dyldInfo: .dyldInfo
        case .dyldInfoOnly: .dyldInfoOnly
        case .loadUpwardDylib: .loadUpwardDylib
        case .versionMinMacosx: .versionMinMacosx
        case .versionMinIphoneos: .versionMinIphoneos
        case .functionStarts: .functionStarts
        case .dyldEnvironment: .dyldEnvironment
        case .main: .main
        case .dataInCode: .dataInCode
        case .sourceVersion: .sourceVersion
        case .dylibCodeSignDrs: .dylibCodeSignDrs
        case .encryptionInfo64: .encryptionInfo64
        case .linkerOption: .linkerOption
        case .linkerOptimizationHint: .linkerOptimizationHint
        case .versionMinTvos: .versionMinTvos
        case .versionMinWatchos: .versionMinWatchos
        case .note: .note
        case .buildVersion: .buildVersion
        case .dyldExportsTrie: .dyldExportsTrie
        case .dyldChainedFixups: .dyldChainedFixups
        case .filesetEntry: .filesetEntry
        case .atomInfo: .atomInfo
        }
    }
}
