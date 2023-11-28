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
    case segment(segment_command)
    /// LC_SYMTAB
    case symtab(symtab_command)
    /// LC_SYMSEG
    case symseg(symseg_command)
    /// LC_THREAD
    case thread(thread_command)
    /// LC_UNIXTHREAD
    case unixthread(thread_command)
    /// LC_LOADFVMLIB
    case loadfvmlib(fvmlib_command)
    /// LC_IDFVMLIB
    case idfvmlib(fvmlib_command)
    /// LC_IDENT
    case ident(ident_command)
    /// LC_FVMFILE
    case fvmfile(fvmfile_command)
    /// LC_PREPAGE
    case prepage(load_command) // ????
    /// LC_DYSYMTAB
    case dysymtab(dysymtab_command)
    /// LC_LOAD_DYLIB
    case loadDylib(dylib_command)
    /// LC_ID_DYLIB
    case idDylib(dylib_command)
    /// LC_LOAD_DYLINKER
    case loadDylinker(dylinker_command)
    /// LC_ID_DYLINKER
    case idDylinker(dylinker_command)
    /// LC_PREBOUND_DYLIB
    case preboundDylib(prebound_dylib_command)
    /// LC_ROUTINES
    case routines(routines_command)
    /// LC_SUB_FRAMEWORK
    case subFramework(sub_framework_command)
    /// LC_SUB_UMBRELLA
    case subUmbrella(sub_umbrella_command)
    /// LC_SUB_CLIENT
    case subClient(sub_client_command)
    /// LC_SUB_LIBRARY
    case subLibrary(sub_library_command)
    /// LC_TWOLEVEL_HINTS
    case twolevelHints(twolevel_hints_command)
    /// LC_PREBIND_CKSUM
    case prebindCksum(prebind_cksum_command)
    /// LC_LOAD_WEAK_DYLIB
    case loadWeakDylib(dylib_command)
    /// LC_SEGMENT_64
    case segment64(segment_command_64)
    /// LC_ROUTINES_64
    case routines64(routines_command_64)
    /// LC_UUID
    case uuid(uuid_command)
    /// LC_RPATH
    case rpath(rpath_command)
    /// LC_CODE_SIGNATURE
    case codeSignature(linkedit_data_command)
    /// LC_SEGMENT_SPLIT_INFO
    case segmentSplitInfo(linkedit_data_command)
    /// LC_REEXPORT_DYLIB
    case reexportDylib(dylib_command)
    /// LC_LAZY_LOAD_DYLIB
    case lazyLoadDylib(dylib_command)
    /// LC_ENCRYPTION_INFO
    case encryptionInfo(encryption_info_command)
    /// LC_DYLD_INFO
    case dyldInfo(dyld_info_command)
    /// LC_DYLD_INFO_ONLY
    case dyldInfoOnly(dyld_info_command)
    /// LC_LOAD_UPWARD_DYLIB
    case loadUpwardDylib(load_command)
    /// LC_VERSION_MIN_MACOSX
    case versionMinMacosx(version_min_command)
    /// LC_VERSION_MIN_IPHONEOS
    case versionMinIphoneos(version_min_command)
    /// LC_FUNCTION_STARTS
    case functionStarts(linkedit_data_command)
    /// LC_DYLD_ENVIRONMENT
    case dyldEnvironment(dylinker_command)
    /// LC_MAIN
    case main(entry_point_command)
    /// LC_DATA_IN_CODE
    case dataInCode(linkedit_data_command)
    /// LC_SOURCE_VERSION
    case sourceVersion(source_version_command)
    /// LC_DYLIB_CODE_SIGN_DRS
    case dylibCodeSignDrs(linkedit_data_command)
    /// LC_ENCRYPTION_INFO_64
    case encryptionInfo64(encryption_info_command_64)
    /// LC_LINKER_OPTION
    case linkerOption(linker_option_command)
    /// LC_LINKER_OPTIMIZATION_HINT
    case linkerOptimizationHint(linkedit_data_command)
    /// LC_VERSION_MIN_TVOS
    case versionMinTvos(version_min_command)
    /// LC_VERSION_MIN_WATCHOS
    case versionMinWatchos(version_min_command)
    /// LC_NOTE
    case note(note_command)
    /// LC_BUILD_VERSION
    case buildVersion(build_version_command)
    /// LC_DYLD_EXPORTS_TRIE
    case dyldExportsTrie(linkedit_data_command)
    /// LC_DYLD_CHAINED_FIXUPS
    case dyldChainedFixups(linkedit_data_command)
    /// LC_FILESET_ENTRY
    case filesetEntry(fileset_entry_command)
    /// LC_ATOM_INFO
    case atomInfo(linkedit_data_command)
}

extension LoadCommand {
    public static func convert(_ commandPtr: UnsafePointer<load_command>) -> LoadCommand? {
        let rawPointer = UnsafeRawPointer(commandPtr)
        let command = commandPtr.pointee
        guard let type = LoadCommandType(rawValue: command.cmd) else {
            return nil
        }
        switch type {
        case .segment:
            return .segment(rawPointer.autoBoundPointee())
        case .symtab:
            return .symtab(rawPointer.autoBoundPointee())
        case .symseg:
            return .symseg(rawPointer.autoBoundPointee())
        case .thread:
            return .thread(rawPointer.autoBoundPointee())
        case .unixthread:
            return .unixthread(rawPointer.autoBoundPointee())
        case .loadfvmlib:
            return .loadfvmlib(rawPointer.autoBoundPointee())
        case .idfvmlib:
            return .idfvmlib(rawPointer.autoBoundPointee())
        case .ident:
            return .ident(rawPointer.autoBoundPointee())
        case .fvmfile:
            return .fvmfile(rawPointer.autoBoundPointee())
        case .prepage:
            return .prepage(rawPointer.autoBoundPointee())
        case .dysymtab:
            return .dysymtab(rawPointer.autoBoundPointee())
        case .loadDylib:
            return .loadDylib(rawPointer.autoBoundPointee())
        case .idDylib:
            return .idDylib(rawPointer.autoBoundPointee())
        case .loadDylinker:
            return .loadDylinker(rawPointer.autoBoundPointee())
        case .idDylinker:
            return .idDylinker(rawPointer.autoBoundPointee())
        case .preboundDylib:
            return .preboundDylib(rawPointer.autoBoundPointee())
        case .routines:
            return .routines(rawPointer.autoBoundPointee())
        case .subFramework:
            return .subFramework(rawPointer.autoBoundPointee())
        case .subUmbrella:
            return .subUmbrella(rawPointer.autoBoundPointee())
        case .subClient:
            return .subClient(rawPointer.autoBoundPointee())
        case .subLibrary:
            return .subLibrary(rawPointer.autoBoundPointee())
        case .twolevelHints:
            return .twolevelHints(rawPointer.autoBoundPointee())
        case .prebindCksum:
            return .prebindCksum(rawPointer.autoBoundPointee())
        case .loadWeakDylib:
            return .loadWeakDylib(rawPointer.autoBoundPointee())
        case .segment64:
            return .segment64(rawPointer.autoBoundPointee())
        case .routines64:
            return .routines64(rawPointer.autoBoundPointee())
        case .uuid:
            return .uuid(rawPointer.autoBoundPointee())
        case .rpath:
            return .rpath(rawPointer.autoBoundPointee())
        case .codeSignature:
            return .codeSignature(rawPointer.autoBoundPointee())
        case .segmentSplitInfo:
            return .segmentSplitInfo(rawPointer.autoBoundPointee())
        case .reexportDylib:
            return .reexportDylib(rawPointer.autoBoundPointee())
        case .lazyLoadDylib:
            return .lazyLoadDylib(rawPointer.autoBoundPointee())
        case .encryptionInfo:
            return .encryptionInfo(rawPointer.autoBoundPointee())
        case .dyldInfo:
            return .dyldInfo(rawPointer.autoBoundPointee())
        case .dyldInfoOnly:
            return .dyldInfoOnly(rawPointer.autoBoundPointee())
        case .loadUpwardDylib:
            return .loadUpwardDylib(rawPointer.autoBoundPointee())
        case .versionMinMacosx:
            return .versionMinMacosx(rawPointer.autoBoundPointee())
        case .versionMinIphoneos:
            return .versionMinIphoneos(rawPointer.autoBoundPointee())
        case .functionStarts:
            return .functionStarts(rawPointer.autoBoundPointee())
        case .dyldEnvironment:
            return .dyldEnvironment(rawPointer.autoBoundPointee())
        case .main:
            return .main(rawPointer.autoBoundPointee())
        case .dataInCode:
            return .dataInCode(rawPointer.autoBoundPointee())
        case .sourceVersion:
            return .sourceVersion(rawPointer.autoBoundPointee())
        case .dylibCodeSignDrs:
            return .dylibCodeSignDrs(rawPointer.autoBoundPointee())
        case .encryptionInfo64:
            return .encryptionInfo64(rawPointer.autoBoundPointee())
        case .linkerOption:
            return .linkerOption(rawPointer.autoBoundPointee())
        case .linkerOptimizationHint:
            return .linkerOptimizationHint(rawPointer.autoBoundPointee())
        case .versionMinTvos:
            return .versionMinTvos(rawPointer.autoBoundPointee())
        case .versionMinWatchos:
            return .versionMinWatchos(rawPointer.autoBoundPointee())
        case .note:
            return .note(rawPointer.autoBoundPointee())
        case .buildVersion:
            return .buildVersion(rawPointer.autoBoundPointee())
        case .dyldExportsTrie:
            return .dyldExportsTrie(rawPointer.autoBoundPointee())
        case .dyldChainedFixups:
            return .dyldChainedFixups(rawPointer.autoBoundPointee())
        case .filesetEntry:
            return .filesetEntry(rawPointer.autoBoundPointee())
        case .atomInfo:
            return .atomInfo(rawPointer.autoBoundPointee())
        }
    }
}

extension UnsafeRawPointer {
    func autoBoundPointee<Out>() -> Out {
        bindMemory(to: Out.self, capacity: 1).pointee
    }
}
