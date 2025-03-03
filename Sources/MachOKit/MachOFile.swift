//
//  MachOFile.swift
//
//
//  Created by p-x9 on 2023/12/04.
//
//

import Foundation

public class MachOFile: MachORepresentable {
    /// URL of the file actually loaded
    public let url: URL

    /// Path of machO.
    ///
    /// If read from dyld cache, may not match ``url`` value.
    public let imagePath: String

    let fileHandle: FileHandle

    /// A Boolean value that indicates whether the byte is swapped or not.
    ///
    /// True if the endianness of the currently running CPU is different from the endianness of the target MachO file.
    public private(set) var isSwapped: Bool

    public var is64Bit: Bool { header.magic.is64BitMach }
    public var headerSize: Int {
        is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
    }

    public let header: MachHeader

    /// File offset of header start
    public let headerStartOffset: Int

    /// File offset of header start (dyld cache file)
    public let headerStartOffsetInCache: Int

    /// File offset of load commands list start
    public var cmdsStartOffset: Int {
        headerStartOffset + headerStartOffsetInCache + headerSize
    }

    public var loadCommands: LoadCommands {
        let data = fileHandle.readData(
            offset: UInt64(cmdsStartOffset),
            size: Int(header.sizeofcmds)
        )

        return .init(
            data: data,
            numberOfCommands: Int(header.ncmds),
            isSwapped: isSwapped
        )
    }

    public convenience init(
        url: URL,
        headerStartOffset: Int = 0
    ) throws {
        try self.init(
            url: url,
            imagePath: url.path,
            headerStartOffset: headerStartOffset,
            headerStartOffsetInCache: 0
        )
    }

    public convenience init(
        url: URL,
        imagePath: String,
        headerStartOffsetInCache: Int
    ) throws {
        try self.init(
            url: url,
            imagePath: imagePath,
            headerStartOffset: 0,
            headerStartOffsetInCache: headerStartOffsetInCache
        )
    }

    private init(
        url: URL,
        imagePath: String,
        headerStartOffset: Int,
        headerStartOffsetInCache: Int
    ) throws {
        self.url = url
        self.imagePath = imagePath
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle

        self.headerStartOffset = headerStartOffset
        self.headerStartOffsetInCache = headerStartOffsetInCache

        var header: MachHeader = fileHandle.read(
            offset: UInt64(headerStartOffset + headerStartOffsetInCache)
        )

        let isSwapped = header.magic.isSwapped
        if isSwapped {
            swap_mach_header(&header.layout, NXHostByteOrder())
        }

        self.isSwapped = isSwapped
        self.header = header
    }

    deinit {
        fileHandle.closeFile()
    }
}

extension MachOFile {
    public var rpaths: [String] {
        loadCommands
            .compactMap { cmd in
                if case let .rpath(info) = cmd { info.path(in: self) } else { nil }
            }
    }
}

extension MachOFile {
    public var dependencies: [DependedDylib] {
        var dependencies = [DependedDylib]()
        for cmd in loadCommands {
            switch cmd {
            case let .loadDylib(cmd):
                var flags: DylibUseFlags = []
                if let dylibUseCmd = cmd.dylibUseCommand(in: self) {
                    flags = dylibUseCmd.flags
                }
                let lib = cmd.dylib(in: self)
                dependencies.append(.init(dylib: lib, type: .load, useFlags: flags))
            case let .loadWeakDylib(cmd):
                var flags: DylibUseFlags = []
                if let dylibUseCmd = cmd.dylibUseCommand(in: self) {
                    flags = dylibUseCmd.flags
                }
                let lib = cmd.dylib(in: self)
                dependencies.append(.init(dylib: lib, type: .load, useFlags: flags))
            case let .reexportDylib(cmd):
                let lib = cmd.dylib(in: self)
                dependencies.append(.init(dylib: lib, type: .reexport))
            case let .loadUpwardDylib(cmd):
                let lib = cmd.dylib(in: self)
                dependencies.append(.init(dylib: lib, type: .upwardLoad))
            case let .lazyLoadDylib(cmd):
                let lib = cmd.dylib(in: self)
                dependencies.append(.init(dylib: lib, type: .lazyLoad))
            default: continue
            }
        }
        return dependencies
    }
}

extension MachOFile {
    public var sections64: [Section64] {
        segments64.map {
            $0.sections(in: self)
        }.flatMap { $0 }
    }

    public var sections32: [Section] {
        segments32.map {
            $0.sections(in: self)
        }.flatMap { $0 }
    }
}

extension MachOFile {
    public var symbols64: Symbols64? {
        guard is64Bit else {
            return nil
        }
        if let symtab = loadCommands.symtab {
            return Symbols64(
                machO: self,
                symtab: symtab
            )
        }
        return nil
    }

    public var symbols32: Symbols? {
        guard !is64Bit else {
            return nil
        }
        if let symtab = loadCommands.symtab {
            return Symbols(
                machO: self,
                symtab: symtab
            )
        }
        return nil
    }

    public typealias IndirectSymbols = DataSequence<IndirectSymbol>

    public var indirectSymbols: IndirectSymbols? {
        guard let dysymtab = loadCommands.dysymtab else { return nil }

        let offset: UInt64 = numericCast(headerStartOffset) + numericCast(dysymtab.indirectsymoff)
        let numberOfElements: Int = numericCast(dysymtab.nindirectsyms)

        return fileHandle.readDataSequence(
            offset: offset,
            numberOfElements: numberOfElements,
            swapHandler: { data in
                guard self.isSwapped else { return }
                data.withUnsafeMutableBytes {
                    let buffer = $0.assumingMemoryBound(to: UInt32.self)
                    for i in 0 ..< numberOfElements {
                        buffer[i] = buffer[i].byteSwapped
                    }
                }
            }
        )
    }
}

extension MachOFile {
    public var symbolStrings: Strings? {
        if let symtab = loadCommands.symtab {
            return Strings(
                machO: self,
                offset: headerStartOffset + Int(symtab.stroff),
                size: Int(symtab.strsize)
            )
        }
        return nil
    }
}

extension MachOFile {
    /// Strings in `__TEXT, __cstring` section
    public var cStrings: Strings? {
        if is64Bit, let text = loadCommands.text64 {
            let cstrings = text.sections(in: self).first {
                $0.sectionName == "__cstring"
            }
            guard let cstrings else { return nil }
            return cstrings.strings(in: self)
        } else if let text = loadCommands.text {
            let cstrings = text.sections(in: self).first {
                $0.sectionName == "__cstring"
            }
            guard let cstrings else { return nil }
            return cstrings.strings(in: self)
        }
        return nil
    }

    public var allCStringTables: [Strings] {
        let sections: [any SectionProtocol]
        if is64Bit {
            let segments = loadCommands.infos(of: LoadCommand.segment64)
            sections = segments.flatMap {
                $0.sections(in: self)
            }
        } else {
            let segments = loadCommands.infos(of: LoadCommand.segment)
            sections = segments.flatMap {
                $0.sections(in: self)
            }
        }

        return sections.reduce(into: []) { partialResult, section in
            if let strings = section.strings(in: self) {
                partialResult += [strings]
            }
        }
    }

    /// All strings in `__TEXT` segment
    public var allCStrings: [String] {
        allCStringTables.flatMap { $0.map(\.string) }
    }

    public var uStrings: UTF16Strings? {
        guard let section = sections.first(where: {
            $0.sectionName == "__ustring"
        }) else { return nil }

        let offset = headerStartOffset + section.offset

        return .init(
            machO: self,
            offset: offset,
            size: section.size,
            isLittleEndian: true
        )
    }
}

extension MachOFile {
    public var rebaseOperations: RebaseOperations? {
        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)
        guard let info else { return nil }
        return .init(machO: self, info: info.layout)
    }
}

extension MachOFile {
    public var bindOperations: BindOperations? {
        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)
        guard let info else { return nil }
        return .init(
            machO: self,
            info: info.layout,
            kind: .normal
        )
    }

    public var weakBindOperations: BindOperations? {
        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)
        guard let info else { return nil }
        return .init(
            machO: self,
            info: info.layout,
            kind: .weak
        )
    }

    public var lazyBindOperations: BindOperations? {
        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)
        guard let info else { return nil }
        return .init(
            machO: self,
            info: info.layout,
            kind: .lazy
        )
    }
}

extension MachOFile {
    public var exportTrie: ExportTrie? {
        let ldVersion: Version? = {
            loadCommands.info(of: LoadCommand.buildVersion)?
                .tools(in: self)
                .first(where: { $0.tool == .ld })?
                .version
        }()

        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)

        if let info {
            return .init(
                machO: self,
                info: info.layout,
                ldVersion: ldVersion
            )
        }

        guard let export = loadCommands.info(of: LoadCommand.dyldExportsTrie) else {
            return nil
        }

        return .init(
            machO: self,
            export: export.layout,
            ldVersion: ldVersion
        )
    }

    public var exportedSymbols: [ExportedSymbol] {
        guard let exportTrie else {
            return []
        }
        return exportTrie.exportedSymbols
    }
}

extension MachOFile {
    public var functionStarts: FunctionStarts? {
        guard let functionStarts = loadCommands.functionStarts,
              functionStarts.datasize > 0 else {
            return nil
        }

        if let text = loadCommands.text64 {
            return .init(
                machO: self,
                functionStarts: functionStarts.layout,
                text: text
            )
        } else if let text = loadCommands.text {
            return .init(
                machO: self,
                functionStarts: functionStarts.layout,
                text: text
            )
        }
        return nil
    }
}

extension MachOFile {
    public var dataInCode: AnyRandomAccessCollection<DataInCodeEntry>? {
        guard let dataInCode = loadCommands.dataInCode,
              dataInCode.datasize > 0 else {
            return nil
        }

        let entries: DataSequence<DataInCodeEntry> = fileHandle.readDataSequence(
            offset: numericCast(headerStartOffset) + numericCast(dataInCode.dataoff),
            numberOfElements: numericCast(dataInCode.datasize) / DataInCodeEntry.layoutSize
        )

        if isSwapped {
            return AnyRandomAccessCollection(
                entries.lazy.map {
                    DataInCodeEntry(
                        layout: .init(
                            offset: $0.offset.byteSwapped,
                            length: $0.length.byteSwapped,
                            kind: $0.layout.kind.byteSwapped
                        )
                    )
                }
            )
        }

        return AnyRandomAccessCollection(entries)
    }
}

extension MachOFile {
    public var dyldChainedFixups: DyldChainedFixups? {
        guard let info = loadCommands.dyldChainedFixups else {
            return nil
        }
        let data = fileHandle.readData(
            offset: UInt64(headerStartOffset) + numericCast(info.dataoff),
            size: numericCast(info.datasize)
        )

        return .init(
            data: data,
            isSwapped: isSwapped
        )
    }
}

extension MachOFile {
    public var externalRelocations: DataSequence<Relocation>? {
        guard let dysymtab = loadCommands.dysymtab else {
            return nil
        }
        return fileHandle.readDataSequence(
            offset: numericCast(dysymtab.extreloff),
            numberOfElements: numericCast(dysymtab.nextrel),
            swapHandler: { data in
                guard self.isSwapped else { return }
                data.withUnsafeMutableBytes {
                    guard let baseAddress = $0.baseAddress else { return }
                    let ptr = baseAddress
                        .assumingMemoryBound(to: relocation_info.self)
                    swap_relocation_info(ptr, dysymtab.nextrel, NXHostByteOrder())
                }
            }
        )
    }
}

extension MachOFile {
    public var isEncrypted: Bool {
        if let encryptionInfo = loadCommands.encryptionInfo {
            return encryptionInfo.cryptid != 0
        }
        if let encryptionInfo = loadCommands.encryptionInfo64 {
            return encryptionInfo.cryptid != 0
        }
        return false
    }
}

extension MachOFile {
    public var codeSign: CodeSign? {
        guard let info = loadCommands.codeSignature else {
            return nil
        }
        let data = fileHandle.readData(
            offset: UInt64(headerStartOffset) + numericCast(info.dataoff),
            size: numericCast(info.datasize)
        )

        return .init(data: data)
    }
}

extension MachOFile {
    /// A Boolean value that indicates whether this machO file was loaded from dyld cache
    public var isLoadedFromDyldCache: Bool {
        headerStartOffsetInCache > 0
    }
}

extension MachOFile {
    public var cfStrings64: DataSequence<CFString64>? {
        guard let section = sections64.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }

        let offset = headerStartOffset + section.offset
        let count = section.size / CFString64.layoutSize

        return fileHandle.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: count
        )
    }

    public var cfStrings32: DataSequence<CFString32>? {
        guard let section = sections32.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }

        let offset = headerStartOffset + section.offset
        let count = section.size / CFString32.layoutSize

        return fileHandle.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: count
        )
    }
}

extension MachOFile {
    // https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/common/MetadataVisitor.cpp#L262
    public func resolveRebase(at offset: UInt64) -> UInt64? {
        if isLoadedFromDyldCache,
           let cache = try? DyldCache(url: url) {
            return cache.resolveRebase(at: offset)
        }

        guard let chainedFixup = dyldChainedFixups,
              let pointer = chainedFixup.pointer(for: offset, in: self) else {
            return nil
        }

        guard pointer.fixupInfo.rebase != nil,
              let offset = pointer.rebaseTargetRuntimeOffset(for: self) else {
            return nil
        }
        return offset
    }

    public func resolveOptionalRebase(at offset: UInt64) -> UInt64? {
        if isLoadedFromDyldCache,
           let cache = try? DyldCache(url: url) {
            return cache.resolveOptionalRebase(at: offset)
        }

        guard let chainedFixup = dyldChainedFixups,
              let pointer = chainedFixup.pointer(for: offset, in: self) else {
            return nil
        }

        guard pointer.fixupInfo.rebase != nil,
              let offset = pointer.rebaseTargetRuntimeOffset(for: self) else {
            return nil
        }
        if is64Bit {
            let value: UInt64 = fileHandle.read(
                offset: numericCast(headerStartOffset + pointer.offset)
            )
            if value == 0 { return nil }
        } else {
            let value: UInt32 = fileHandle.read(
                offset: numericCast(headerStartOffset + pointer.offset)
            )
            if value == 0 { return nil }
        }
        return offset
    }


    public func resolveBind(
        at offset: UInt64
    ) -> (DyldChainedImport, addend: UInt64)? {
        guard let chainedFixup = dyldChainedFixups,
              let startsInImage = chainedFixup.startsInImage else {
            return nil
        }
        let startsInSegments = chainedFixup.startsInSegments(
            of: startsInImage
        )

        for segment in startsInSegments {
            let pointers = chainedFixup.pointers(of: segment, in: self)
            guard let pointer = pointers.first(where: {
                $0.offset == offset
            }) else { continue }
            guard pointer.fixupInfo.bind != nil,
                  let (ordinal, addend) = pointer.bindOrdinalAndAddend(for: self) else {
                return nil
            }
            return (chainedFixup.imports[ordinal], addend)
        }
        return nil
    }
}

extension MachOFile {
    /// Bitmask to get a valid range of vmaddr from raw vmaddr
    ///
    /// | Arch | `MACH_VM_MAX_ADDRESS` | mask |
    /// |---------|------------------|----------|
    /// | **arm** | `0x80000000` | `0x7FFFFFFF` |
    /// | **arm64 (mac or driver)** | `0x00007FFFFE000000` | `0x00007FFFFFFFFFFF` |
    /// | **arm64 (other)** | `0x0000000FC0000000` | `0x0000000FFFFFFFFF` |
    /// | **i386** | `0x00007FFFFFE00000` | `0x00007FFFFFFFFFFF` |
    ///
    /// [xnu implementation](https://github.com/apple-oss-distributions/xnu/blob/8d741a5de7ff4191bf97d57b9f54c2f6d4a15585/osfmk/mach/arm/vm_param.h#L126)
    private var vmaddrMask: UInt64? {
        switch header.cpuType {
        case .x86:
            return 0xFFFFFFFF
        case .i386:
            return 0xFFFFFFFF
        case .x86_64:
            return 0x00007FFFFFFFFFFF
        case .arm:
            return 0x7FFFFFFF
        case .arm64:
            if let platform = loadCommands.info(of: LoadCommand.buildVersion)?.platform {
                if [
                    .macOS,
                    .driverKit
                ].contains(platform) || isMacOS == true {
                    return 0x00007FFFFFFFFFFF
                } else {
                    return 0x0000000FFFFFFFFF
                }
            }
            return 0x0000000FFFFFFFFF // FIXME: fallback

        case .arm64_32:
            return 0x7FFFFFFF
        default:
            return nil
        }
    }
}

extension MachOFile {
    private var isMacOS: Bool? {
        let loadCommands = loadCommands
        if let platform = loadCommands.info(of: LoadCommand.buildVersion)?.platform  {
            return [
                .macOS,
                .macOSExclaveKit,
                .macOSExclaveCore,
                .macCatalyst
            ].contains(
                platform
            )
        }
        if loadCommands.info(of: LoadCommand.versionMinMacosx) != nil {
            return true
        }

        if loadCommands.info(of: LoadCommand.versionMinIphoneos) != nil ||
            loadCommands.info(of: LoadCommand.versionMinWatchos) != nil ||
            loadCommands.info(of: LoadCommand.versionMinTvos) != nil {
            return false
        }

        if header.isInDyldCache,
           let cache = try? DyldCache(url: url) {
            return cache.header.platform == .macOS
        }

        return nil
    }
}
