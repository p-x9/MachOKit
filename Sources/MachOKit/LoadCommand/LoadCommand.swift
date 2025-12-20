//
//  LoadCommand.swift
//
//
//  Created by p-x9 on 2023/11/28.
//
//

import Foundation

public enum LoadCommand: Sendable {
    /// LC_SEGMENT
    case segment(SegmentCommand)
    /// LC_SYMTAB
    case symtab(LoadCommandInfo<symtab_command>)
    /// LC_SYMSEG
    case symseg(LoadCommandInfo<symseg_command>)
    /// LC_THREAD
    case thread(ThreadCommand)
    /// LC_UNIXTHREAD
    case unixthread(ThreadCommand)
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
    case loadDylinker(DylinkerCommand)
    /// LC_ID_DYLINKER
    case idDylinker(DylinkerCommand)
    /// LC_PREBOUND_DYLIB
    case preboundDylib(LoadCommandInfo<prebound_dylib_command>)
    /// LC_ROUTINES
    case routines(LoadCommandInfo<routines_command>)
    /// LC_SUB_FRAMEWORK
    case subFramework(SubFrameworkCommand)
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
    case uuid(UUIDCommand)
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
    case encryptionInfo(EncryptionInfoCommand)
    /// LC_DYLD_INFO
    case dyldInfo(LoadCommandInfo<dyld_info_command>)
    /// LC_DYLD_INFO_ONLY
    case dyldInfoOnly(LoadCommandInfo<dyld_info_command>)
    /// LC_LOAD_UPWARD_DYLIB
    case loadUpwardDylib(DylibCommand)
    /// LC_VERSION_MIN_MACOSX
    case versionMinMacosx(VersionMinCommand)
    /// LC_VERSION_MIN_IPHONEOS
    case versionMinIphoneos(VersionMinCommand)
    /// LC_FUNCTION_STARTS
    case functionStarts(LoadCommandInfo<linkedit_data_command>)
    /// LC_DYLD_ENVIRONMENT
    case dyldEnvironment(DylinkerCommand)
    /// LC_MAIN
    case main(EntryPointCommand)
    /// LC_DATA_IN_CODE
    case dataInCode(LoadCommandInfo<linkedit_data_command>)
    /// LC_SOURCE_VERSION
    case sourceVersion(SourceVersionCommand)
    /// LC_DYLIB_CODE_SIGN_DRS
    case dylibCodeSignDrs(LoadCommandInfo<linkedit_data_command>)
    /// LC_ENCRYPTION_INFO_64
    case encryptionInfo64(EncryptionInfoCommand64)
    /// LC_LINKER_OPTION
    case linkerOption(LinkerOptionCommand)
    /// LC_LINKER_OPTIMIZATION_HINT
    case linkerOptimizationHint(LoadCommandInfo<linkedit_data_command>)
    /// LC_VERSION_MIN_TVOS
    case versionMinTvos(VersionMinCommand)
    /// LC_VERSION_MIN_WATCHOS
    case versionMinWatchos(VersionMinCommand)
    /// LC_NOTE
    case note(NoteCommand)
    /// LC_BUILD_VERSION
    case buildVersion(BuildVersionCommand)
    /// LC_DYLD_EXPORTS_TRIE
    case dyldExportsTrie(LoadCommandInfo<linkedit_data_command>)
    /// LC_DYLD_CHAINED_FIXUPS
    case dyldChainedFixups(LoadCommandInfo<linkedit_data_command>)
    /// LC_FILESET_ENTRY
    case filesetEntry(FilesetEntryCommand)
    /// LC_ATOM_INFO
    case atomInfo(LoadCommandInfo<linkedit_data_command>)
    /// LC_FUNCTION_VARIANTS
    case functionVariants(LoadCommandInfo<linkedit_data_command>)
    /// LC_FUNCTION_VARIANT_FIXUPS
    case functionVariantFixups(LoadCommandInfo<linkedit_data_command>)
    /// LC_TARGET_TRIPLE
    case targetTriple(TargetTripleCommand)

    /// LC_AOT_METADATA
    case aotMetadata(AotMetadataCommand)
}

extension LoadCommand {
    // swiftlint:disable:next function_body_length
    public static func convert(
        _ commandPtr: UnsafePointer<load_command>,
        offset: Int
    ) -> LoadCommand? {
        let rawPointer = UnsafeRawPointer(commandPtr)
        let command = commandPtr.pointee
        guard let type = LoadCommandType(rawValue: command.cmd) ??
                LoadCommandType(rawValue: command.cmd.byteSwapped) else {
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
        case .functionVariants:
            return .functionVariants(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .functionVariantFixups:
            return .functionVariantFixups(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .targetTriple:
            return .targetTriple(
                .init(rawPointer.autoBoundPointee(), offset: offset)
            )
        case .aotMetadata:
            return .aotMetadata(
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
        case .functionVariants: .functionVariants
        case .functionVariantFixups: .functionVariantFixups
        case .targetTriple: .targetTriple
        case .aotMetadata: .aotMetadata
        }
    }
}

extension LoadCommand {
    public var commandSize: Int {
        let cmdSize = switch self {
        case let .segment(info): info.cmdsize
        case let .symtab(info): info.cmdsize
        case let .symseg(info): info.cmdsize
        case let .thread(info): info.cmdsize
        case let .unixthread(info): info.cmdsize
        case let .loadfvmlib(info): info.cmdsize
        case let .idfvmlib(info): info.cmdsize
        case let .ident(info): info.cmdsize
        case let .fvmfile(info): info.cmdsize
        case let .prepage(info): info.cmdsize
        case let .dysymtab(info): info.cmdsize
        case let .loadDylib(info): info.cmdsize
        case let .idDylib(info): info.cmdsize
        case let .loadDylinker(info): info.cmdsize
        case let .idDylinker(info): info.cmdsize
        case let .preboundDylib(info): info.cmdsize
        case let .routines(info): info.cmdsize
        case let .subFramework(info): info.cmdsize
        case let .subUmbrella(info): info.cmdsize
        case let .subClient(info): info.cmdsize
        case let .subLibrary(info): info.cmdsize
        case let .twolevelHints(info): info.cmdsize
        case let .prebindCksum(info): info.cmdsize
        case let .loadWeakDylib(info): info.cmdsize
        case let .segment64(info): info.cmdsize
        case let .routines64(info): info.cmdsize
        case let .uuid(info): info.cmdsize
        case let .rpath(info): info.cmdsize
        case let .codeSignature(info): info.cmdsize
        case let .segmentSplitInfo(info): info.cmdsize
        case let .reexportDylib(info): info.cmdsize
        case let .lazyLoadDylib(info): info.cmdsize
        case let .encryptionInfo(info): info.cmdsize
        case let .dyldInfo(info): info.cmdsize
        case let .dyldInfoOnly(info): info.cmdsize
        case let .loadUpwardDylib(info): info.cmdsize
        case let .versionMinMacosx(info): info.cmdsize
        case let .versionMinIphoneos(info): info.cmdsize
        case let .functionStarts(info): info.cmdsize
        case let .dyldEnvironment(info): info.cmdsize
        case let .main(info): info.cmdsize
        case let .dataInCode(info): info.cmdsize
        case let .sourceVersion(info): info.cmdsize
        case let .dylibCodeSignDrs(info): info.cmdsize
        case let .encryptionInfo64(info): info.cmdsize
        case let .linkerOption(info): info.cmdsize
        case let .linkerOptimizationHint(info): info.cmdsize
        case let .versionMinTvos(info): info.cmdsize
        case let .versionMinWatchos(info): info.cmdsize
        case let .note(info): info.cmdsize
        case let .buildVersion(info): info.cmdsize
        case let .dyldExportsTrie(info): info.cmdsize
        case let .dyldChainedFixups(info): info.cmdsize
        case let .filesetEntry(info): info.cmdsize
        case let .atomInfo(info): info.cmdsize
        case let .functionVariants(info): info.cmdsize
        case let .functionVariantFixups(info): info.cmdsize
        case let .targetTriple(info): info.cmdsize
        case let .aotMetadata(info): info.cmdsize
        }
        return numericCast(cmdSize)
    }
}

extension LoadCommand {
    public var info: any LoadCommandWrapper {
        switch self {
        case let .segment(info): info
        case let .symtab(info): info
        case let .symseg(info): info
        case let .thread(info): info
        case let .unixthread(info): info
        case let .loadfvmlib(info): info
        case let .idfvmlib(info): info
        case let .ident(info): info
        case let .fvmfile(info): info
        case let .prepage(info): info
        case let .dysymtab(info): info
        case let .loadDylib(info): info
        case let .idDylib(info): info
        case let .loadDylinker(info): info
        case let .idDylinker(info): info
        case let .preboundDylib(info): info
        case let .routines(info): info
        case let .subFramework(info): info
        case let .subUmbrella(info): info
        case let .subClient(info): info
        case let .subLibrary(info): info
        case let .twolevelHints(info): info
        case let .prebindCksum(info): info
        case let .loadWeakDylib(info): info
        case let .segment64(info): info
        case let .routines64(info): info
        case let .uuid(info): info
        case let .rpath(info): info
        case let .codeSignature(info): info
        case let .segmentSplitInfo(info): info
        case let .reexportDylib(info): info
        case let .lazyLoadDylib(info): info
        case let .encryptionInfo(info): info
        case let .dyldInfo(info): info
        case let .dyldInfoOnly(info): info
        case let .loadUpwardDylib(info): info
        case let .versionMinMacosx(info): info
        case let .versionMinIphoneos(info): info
        case let .functionStarts(info): info
        case let .dyldEnvironment(info): info
        case let .main(info): info
        case let .dataInCode(info): info
        case let .sourceVersion(info): info
        case let .dylibCodeSignDrs(info): info
        case let .encryptionInfo64(info): info
        case let .linkerOption(info): info
        case let .linkerOptimizationHint(info): info
        case let .versionMinTvos(info): info
        case let .versionMinWatchos(info): info
        case let .note(info): info
        case let .buildVersion(info): info
        case let .dyldExportsTrie(info): info
        case let .dyldChainedFixups(info): info
        case let .filesetEntry(info): info
        case let .atomInfo(info): info
        case let .functionVariants(info): info
        case let .functionVariantFixups(info): info
        case let .targetTriple(info): info
        case let .aotMetadata(info): info
        }
    }
}

extension LoadCommand {
    /// Offset from mach header trailing
    ///
    /// Convenience accessor of `info.offset`.
    public var offset: Int {
        info.offset
    }

    /// Memory layout of load command
    ///
    /// Convenience accessor of `info.layout`.
    public var layout: Any {
        info.layout
    }
}

extension LoadCommand {
    // swiftlint:disable:next function_body_length
    public func swapped() -> Self {
        switch self {
        case let .segment(info):
            var info = info
            info.swap()
            return .segment(info)
        case let .symtab(info):
            var info = info
            info.swap()
            return .symtab(info)
        case let .symseg(info):
            var info = info
            info.swap()
            return .symseg(info)
        case let .thread(info):
            var info = info
            info.swap()
            return .thread(info)
        case let .unixthread(info):
            var info = info
            info.swap()
            return .unixthread(info)
        case let .loadfvmlib(info):
            var info = info
            info.swap()
            return .loadfvmlib(info)
        case let .idfvmlib(info):
            var info = info
            info.swap()
            return .idfvmlib(info)
        case let .ident(info):
            var info = info
            info.swap()
            return .ident(info)
        case let .fvmfile(info):
            var info = info
            info.swap()
            return .fvmfile(info)
        case let .prepage(info):
            var info = info
            info.swap()
            return .prepage(info)
        case let .dysymtab(info):
            var info = info
            info.swap()
            return .dysymtab(info)
        case let .loadDylib(info):
            var info = info
            info.swap()
            return .loadDylib(info)
        case let .idDylib(info):
            var info = info
            info.swap()
            return .idDylib(info)
        case let .loadDylinker(info):
            var info = info
            info.swap()
            return .loadDylinker(info)
        case let .idDylinker(info):
            var info = info
            info.swap()
            return .idDylinker(info)
        case let .preboundDylib(info):
            var info = info
            info.swap()
            return .preboundDylib(info)
        case let .routines(info):
            var info = info
            info.swap()
            return .routines(info)
        case let .subFramework(info):
            var info = info
            info.swap()
            return .subFramework(info)
        case let .subUmbrella(info):
            var info = info
            info.swap()
            return .subUmbrella(info)
        case let .subClient(info):
            var info = info
            info.swap()
            return .subClient(info)
        case let .subLibrary(info):
            var info = info
            info.swap()
            return .subLibrary(info)
        case let .twolevelHints(info):
            var info = info
            info.swap()
            return .twolevelHints(info)
        case let .prebindCksum(info):
            var info = info
            info.swap()
            return .prebindCksum(info)
        case let .loadWeakDylib(info):
            var info = info
            info.swap()
            return .loadWeakDylib(info)
        case let .segment64(info):
            var info = info
            info.swap()
            return .segment64(info)
        case let .routines64(info):
            var info = info
            info.swap()
            return .routines64(info)
        case let .uuid(info):
            var info = info
            info.swap()
            return .uuid(info)
        case let .rpath(info):
            var info = info
            info.swap()
            return .rpath(info)
        case let .codeSignature(info):
            var info = info
            info.swap()
            return .codeSignature(info)
        case let .segmentSplitInfo(info):
            var info = info
            info.swap()
            return .segmentSplitInfo(info)
        case let .reexportDylib(info):
            var info = info
            info.swap()
            return .reexportDylib(info)
        case let .lazyLoadDylib(info):
            var info = info
            info.swap()
            return .lazyLoadDylib(info)
        case let .encryptionInfo(info):
            var info = info
            info.swap()
            return .encryptionInfo(info)
        case let .dyldInfo(info):
            var info = info
            info.swap()
            return .dyldInfo(info)
        case let .dyldInfoOnly(info):
            var info = info
            info.swap()
            return .dyldInfoOnly(info)
        case let .loadUpwardDylib(info):
            var info = info
            info.swap()
            return .loadUpwardDylib(info)
        case let .versionMinMacosx(info):
            var info = info
            info.swap()
            return .versionMinMacosx(info)
        case let .versionMinIphoneos(info):
            var info = info
            info.swap()
            return .versionMinIphoneos(info)
        case let .functionStarts(info):
            var info = info
            info.swap()
            return .functionStarts(info)
        case let .dyldEnvironment(info):
            var info = info
            info.swap()
            return .dyldEnvironment(info)
        case let .main(info):
            var info = info
            info.swap()
            return .main(info)
        case let .dataInCode(info):
            var info = info
            info.swap()
            return .dataInCode(info)
        case let .sourceVersion(info):
            var info = info
            info.swap()
            return .sourceVersion(info)
        case let .dylibCodeSignDrs(info):
            var info = info
            info.swap()
            return .dylibCodeSignDrs(info)
        case let .encryptionInfo64(info):
            var info = info
            info.swap()
            return .encryptionInfo64(info)
        case let .linkerOption(info):
            var info = info
            info.swap()
            return .linkerOption(info)
        case let .linkerOptimizationHint(info):
            var info = info
            info.swap()
            return .linkerOptimizationHint(info)
        case let .versionMinTvos(info):
            var info = info
            info.swap()
            return .versionMinTvos(info)
        case let .versionMinWatchos(info):
            var info = info
            info.swap()
            return .versionMinWatchos(info)
        case let .note(info):
            var info = info
            info.swap()
            return .note(info)
        case let .buildVersion(info):
            var info = info
            info.swap()
            return .buildVersion(info)
        case let .dyldExportsTrie(info):
            var info = info
            info.swap()
            return .dyldExportsTrie(info)
        case let .dyldChainedFixups(info):
            var info = info
            info.swap()
            return .dyldChainedFixups(info)
        case let .filesetEntry(info):
            var info = info
            info.swap()
            return .filesetEntry(info)
        case let .atomInfo(info):
            var info = info
            info.swap()
            return .atomInfo(info)
        case let .functionVariants(info):
            var info = info
            info.swap()
            return .functionVariants(info)
        case let .functionVariantFixups(info):
            var info = info
            info.swap()
            return .functionVariantFixups(info)
        case let .targetTriple(info):
            var info = info
            info.swap()
            return .targetTriple(info)
        case let .aotMetadata(info):
            var info = info
            info.swap()
            return .aotMetadata(info)
        }
    }
}
