//
//  MachOFile.swift
//
//
//  Created by p-x9 on 2023/12/04.
//
//

import CoreFoundation // for CFByteOrderGetCurrent (Linux)
import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
#else
@_implementationOnly import FileIO
#endif

public class MachOFile: MachORepresentable {
    typealias File = MemoryMappedFile

    /// URL of the file actually loaded
    public let url: URL

    private let _imagePath: String?

    let fileHandle: File

    // Retain the cache to which `self` belongs
    private var _fullCache: FullDyldCache?
    private var _cache: DyldCache?

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
        let data = try! fileHandle.readData(
            offset: cmdsStartOffset,
            length: numericCast(header.sizeofcmds)
        )

        return .init(
            data: data,
            numberOfCommands: numericCast(header.ncmds),
            isSwapped: isSwapped
        )
    }

    public convenience init(
        url: URL,
        headerStartOffset: Int = 0
    ) throws {
        try self.init(
            url: url,
            imagePath: nil,
            headerStartOffset: headerStartOffset,
            headerStartOffsetInCache: 0
        )
    }

    public convenience init(
        url: URL,
        imagePath: String? = nil,
        headerStartOffsetInCache: Int,
        cache: DyldCache
    ) throws {
        try self.init(
            url: url,
            imagePath: imagePath,
            headerStartOffset: 0,
            headerStartOffsetInCache: headerStartOffsetInCache
        )
        self._cache = cache
    }

    @available(*, deprecated, renamed: "init(url:imagePath:headerStartOffsetInCache:cache:)")
    public convenience init(
        url: URL,
        imagePath: String? = nil,
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
        imagePath: String?,
        headerStartOffset: Int,
        headerStartOffsetInCache: Int
    ) throws {
        self.url = url
        self._imagePath = imagePath
        let fileHandle = try File.open(
            url: url,
            isWritable: false
        )
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
}

extension MachOFile {
    /// The path representing this Mach-O file.
    ///
    /// - For executable binaries, this usually matches the file's ``url`` path.
    /// - For dynamic libraries, this may return the `LC_ID_DYLIB` or `LC_ID_DYLINKER` path embedded in the load commands.
    ///
    /// This property provides the logical path used by the system to identify the Mach-O image,
    /// which can differ from the actual file system location if the file is part of a dyld shared cache.
    public var imagePath: String {
        if let _imagePath { return _imagePath }
        if let idDylib = loadCommands.info(of: LoadCommand.idDylib) {
            return idDylib.dylib(in: self).name
        }
        if let idDylinker = loadCommands.info(of: LoadCommand.idDylinker) {
            return idDylinker.name(in: self)
        }
        return url.path
    }
}

extension MachOFile {
    public var endian: Endian {
        let hostIsLittleEndian = CFByteOrderGetCurrent() == CFByteOrderLittleEndian.rawValue
        return hostIsLittleEndian
        ? (isSwapped ? .big : .little)
        : (isSwapped ? .little : .big)
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

        let offset: UInt64 = numericCast(dysymtab.indirectsymoff)
        let numberOfElements: Int = numericCast(dysymtab.nindirectsyms)

        guard var data = _readLinkEditData(
            offset: numericCast(offset),
            length: MemoryLayout<UInt32>.size * numberOfElements
        ) else { return nil }

        if isSwapped {
            data.withUnsafeMutableBytes {
                let buffer = $0.assumingMemoryBound(to: UInt32.self)
                for i in 0 ..< numberOfElements {
                    buffer[i] = buffer[i].byteSwapped
                }
            }
        }

        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }
}

extension MachOFile {
    public var symbolStrings: Strings? {
        guard let symtab = loadCommands.symtab else {
            return nil
        }
        guard let fileSlice = _fileSliceForLinkEditData(
            offset: numericCast(symtab.stroff),
            length: numericCast(symtab.strsize)
        ) else { return nil }

        return .init(
            fileSlice: fileSlice,
            offset: numericCast(symtab.stroff),
            size: numericCast(symtab.strsize),
            isSwapped: isSwapped
        )
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
            isSwapped: isSwapped
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

        guard let data = _readLinkEditData(
            offset: numericCast(dataInCode.dataoff),
            length: numericCast(dataInCode.datasize)
        ) else { return nil }

        let entries: DataSequence<DataInCodeEntry> = .init(
            data: data,
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
        guard let fileSlice = _fileSliceForLinkEditData(
            offset: numericCast(info.dataoff),
            length: numericCast(info.datasize)
        ) else { return nil }

        return .init(
            fileSice: fileSlice,
            isSwapped: isSwapped
        )
    }
}

extension MachOFile {
    public var externalRelocations: DataSequence<Relocation>? {
        guard let dysymtab = loadCommands.dysymtab else {
            return nil
        }

        let offset: UInt64 = numericCast(dysymtab.extreloff)
        let numberOfElements: Int = numericCast(dysymtab.nextrel)

        guard var data = _readLinkEditData(
            offset: numericCast(offset),
            length: MemoryLayout<UInt64>.size * numberOfElements
        ) else { return nil }

        if isSwapped {
            data.withUnsafeMutableBytes {
                guard let baseAddress = $0.baseAddress else { return }
                let ptr = baseAddress
                    .assumingMemoryBound(to: relocation_info.self)
                swap_relocation_info(ptr, dysymtab.nextrel, NXHostByteOrder())
            }
        }

        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }

    public var classicBindingSymbols: [ClassicBindingSymbol]? {
        _classicBindingSymbols(
            addendLoader: { address in
                guard let fileOffset = fileOffset(of: address) else {
                    return 0
                }
                return fileHandle.read(
                    offset: fileOffset + numericCast(headerStartOffset)
                )
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
        guard let fileSlice = _fileSliceForLinkEditData(
            offset: numericCast(info.dataoff),
            length: numericCast(info.datasize)
        ) else { return nil }

        return .init(
            fileSice: fileSlice
        )
    }
}

extension MachOFile {
    /// A Boolean value that indicates whether this machO file was loaded from dyld cache
    public var isLoadedFromDyldCache: Bool {
        headerStartOffsetInCache > 0
    }

    /// The `DyldCache` object associated with this Mach-O file, if available.
    ///
    /// This property attempts to lazily load the dyld cache based on the file URL.
    /// - If `_cache` has already been set, that value is returned.
    /// - If `fullCache` is available, the corresponding subcache for this file URL is returned.
    /// - Otherwise, this attempts to initialize a new `DyldCache` using the file URL.
    ///
    /// This is mainly used when the Mach-O file originates from a dyld shared cache and requires
    /// access to symbols, sections, or other data spread across subcaches.
    public var cache: DyldCache? {
        if let _cache { return _cache }
        if let fullCache {
            return fullCache.cache(for: url)
        }
        _cache = try? .init(url: url)
        _cache?._fullCache = _fullCache
        return _cache
    }

    /// The `FullDyldCache` object associated with this Mach-O file, if available.
    ///
    /// This property attempts to lazily load the corresponding full dyld cache based on the file URL.
    /// - If `_fullCache` has already been set, that value is returned.
    /// - If `_cache` exists and its `_fullCache` is available, that is returned.
    /// - Otherwise, this tries to load a `FullDyldCache` from a path obtained by removing the last two path extensions of `url`.
    ///
    /// This is primarily used when the Mach-O file originates from a dyld shared cache and data in other
    /// subcache files needs to be accessed.
    public var fullCache: FullDyldCache? {
        if let _fullCache { return _fullCache }
        if let _cache,
           let _fullCache = _cache._fullCache {
            return _fullCache
        }
        _fullCache = try? .init(
            url: url
                .deletingPathExtension()
                .deletingPathExtension()
        )
        _cache?._fullCache = _fullCache
        return _fullCache
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
    /// Info.plist embedded in the MachO binary (__TEXT,__info_plist)
    public var embeddedInfoPlist: [String: Any]? {
        func plist(in section: any SectionProtocol) throws -> [String: Any]? {
            let offset = headerStartOffset + section.offset
            let data = try fileHandle.readData(
                offset: offset,
                length: section.size
            )
            guard let infoPlist = try? PropertyListSerialization.propertyList(
                from: data,
                format: nil
            ) else {
                return nil
            }
            return infoPlist as? [String: Any]
        }

        if let text = loadCommands.text64 {
            guard let __info_plist = text.sections(in: self).first(
                where: { $0.sectionName == "__info_plist" }
            ) else { return nil }
            return try? plist(in: __info_plist)
        } else if let text = loadCommands.text {
            guard let __info_plist = text.sections(in: self).first(
                where: { $0.sectionName == "__info_plist" }
            ) else { return nil }
            return try? plist(in: __info_plist)
        }
        return nil
    }
}

extension MachOFile {
    internal func _fileSliceForLinkEditData(
        offset: Int, // linkedit_data_command->dataoff (linkedit.fileoff + x)
        length: Int
    ) -> File.FileSlice? {
        let text: (any SegmentCommandProtocol)? = loadCommands.text64 ?? loadCommands.text
        let linkedit: (any SegmentCommandProtocol)? = loadCommands.linkedit64 ?? loadCommands.linkedit
        guard let text, let linkedit else { return nil }
        guard linkedit.fileOffset + linkedit.fileSize >= offset + length else { return nil }

        let maxFileOffsetToCheck = text.fileOffset + linkedit.virtualMemoryAddress - text.virtualMemoryAddress
        let isWithinFileRange: Bool = fileHandle.size >= maxFileOffsetToCheck

        // 1) text.vmaddr < linkedit.vmaddr
        // 2) fileoff_diff <= vmaddr_diff
        // 3) If both exist in the same file
        //    text.fileoff < linkedit.fileoff <= text.fileoff + vmaddr_diff
        // 4) if fileHandle.size < text.fileoff + vmaddr_diff
        //    both exist in the same file

        // The linkeditdata in iOS is stored together in a separate, independent cache.
        // (.0x.linkeditdata)
        if isLoadedFromDyldCache && !isWithinFileRange {
            let offset = offset - numericCast(linkedit.fileOffset)
            guard let fullCache = self.fullCache,
                  let fileOffset = fullCache.fileOffset(
                    of: numericCast(linkedit.virtualMemoryAddress + offset)
                  ),
                  let segment = fullCache.fileSegment(
                    forOffset: fileOffset
                  ) else {
                return nil
            }
            return try? segment._file.fileSlice(
                offset: numericCast(fileOffset) - segment.offset,
                length: length
            )
        } else {
            return try? fileHandle.fileSlice(
                offset: headerStartOffset + offset,
                length: length
            )
        }
    }

    /// Reads the data in the linkedit segment appropriately.
    ///
    /// The linkedit data in the machO file obtained from the dyld cache may be separated in a separate sub cache file.
    /// (e.g. dyld cache in iOS except Simulator)
    ///
    /// The data related to the following load command exists in linkedit.
    ///   - symtab
    ///   - dysymtab
    ///   - linkedit_data_command
    ///   - exports trie
    public func _readLinkEditData(
        offset: Int, // linkedit_data_command->dataoff (linkedit.fileoff + x)
        length: Int
    ) -> Data? {
        guard let fileSlice = _fileSliceForLinkEditData(
            offset: offset,
            length: length
        ) else { return nil }
        return try? fileSlice.readAllData()
    }
}

extension MachOFile {
    // https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/common/MetadataVisitor.cpp#L262
    public func resolveRebase(at offset: UInt64) -> UInt64? {
        if isLoadedFromDyldCache,
           let cache = self.cache {
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
           let cache = self.cache {
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
            let value: UInt64 = try! fileHandle.read(
                offset: numericCast(headerStartOffset + pointer.offset)
            )
            if value == 0 { return nil }
        } else {
            let value: UInt32 = try! fileHandle.read(
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
    /// Converts a raw virtual memory address (VM address) into a file offset within the Mach-O file.
    ///
    /// This method handles pointer authentication codes (PAC) and Objective-C tagged pointers,
    /// returning the corresponding offset within the file that contains the Mach-O header.
    /// It does **not** resolve addresses that rely on rebase or bind operations.
    ///
    /// - Note:
    ///   When the Mach-O file originates from a **dyld shared cache**, segments such as `__LINKEDIT` or `__DATA`
    ///   may reside in different subcache files. In such cases, this function returns `nil` if the address
    ///   does not belong to the current subcache file.
    ///
    /// - Parameter rawVMAddr: The raw virtual memory address to convert.
    /// - Returns: The file offset relative to the start of the file that contains the Mach-O header,
    ///   or `nil` if the address does not exist within this file.
    public func fileOffset(of rawVMAddr: UInt64) -> UInt64? {
        let vmaddr = stripPointerTags(of: rawVMAddr)
        if let cache {
            return cache.fileOffset(of: vmaddr)
        }
        for segment in self.segments {
            if segment.virtualMemoryAddress <= vmaddr,
               vmaddr < segment.virtualMemoryAddress + segment.virtualMemorySize {
                return vmaddr + numericCast(segment.fileOffset) - numericCast(segment.virtualMemoryAddress)
            }
            if segment.segmentName == SEG_TEXT,
               vmaddr < segment.virtualMemoryAddress {
                return vmaddr
            }
        }
        return nil
    }
}
