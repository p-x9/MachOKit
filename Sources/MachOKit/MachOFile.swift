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
        fileHandle.seek(toFileOffset: UInt64(cmdsStartOffset))
        let data = fileHandle.readData(ofLength: Int(header.sizeofcmds))

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
        fileHandle.seek(
            toFileOffset: UInt64(headerStartOffset + headerStartOffsetInCache)
        )

        var header = fileHandle.readData(ofLength: MemoryLayout<MachHeader>.size).withUnsafeBytes {
            $0.load(as: MachHeader.self)
        }

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
    public var dependencies: [Dylib] {
        var dependencies = [Dylib]()
        for cmd in loadCommands {
            switch cmd {
            case let .loadDylib(cmd): dependencies.append(cmd.dylib(in: self))
            case let .loadWeakDylib(cmd): dependencies.append(cmd.dylib(in: self))
            case let .reexportDylib(cmd): dependencies.append(cmd.dylib(in: self))
            case let .loadUpwardDylib(cmd): dependencies.append(cmd.dylib(in: self))
            case let .lazyLoadDylib(cmd): dependencies.append(cmd.dylib(in: self))
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
            let cstrings = text.sections(in: self).filter {
                $0.sectionName == "__cstring"
            }.first
            guard let cstrings else { return nil }
            return cstrings.strings(in: self)
        } else if let text = loadCommands.text {
            let cstrings = text.sections(in: self).filter {
                $0.sectionName == "__cstring"
            }.first
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
}

extension MachOFile {
    public var rebaseOperations: RebaseOperations? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first
        guard let info else { return nil }
        return .init(machO: self, info: info.layout)
    }
}

extension MachOFile {
    public var bindOperations: BindOperations? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first
        guard let info else { return nil }
        return .init(
            machO: self,
            info: info.layout,
            kind: .normal
        )
    }

    public var weakBindOperations: BindOperations? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first
        guard let info else { return nil }
        return .init(
            machO: self,
            info: info.layout,
            kind: .weak
        )
    }

    public var lazyBindOperations: BindOperations? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first
        guard let info else { return nil }
        return .init(
            machO: self,
            info: info.layout,
            kind: .lazy
        )
    }
}

extension MachOFile {
    public var exportTrieEntries: ExportTrieEntries? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first

        if let info {
            return .init(machO: self, info: info.layout)
        }

        guard let export = Array(loadCommands.infos(of: LoadCommand.dyldExportsTrie)).first else {
            return nil
        }

        return .init(
            machO: self,
            export: export.layout
        )
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
    public var dataInCode: AnySequence<DataInCodeEntry>? {
        guard let dataInCode = loadCommands.dataInCode,
              dataInCode.datasize > 0 else {
            return nil
        }

        let entries: DataSequence<DataInCodeEntry> = fileHandle.readDataSequence(
            offset: numericCast(headerStartOffset) + numericCast(dataInCode.dataoff),
            numberOfElements: numericCast(dataInCode.datasize) / DataInCodeEntry.layoutSize
        )

        if isSwapped {
            return AnySequence(
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

        return AnySequence(entries)
    }
}

extension MachOFile {
    public var dyldChainedFixups: DyldChainedFixups? {
        guard let info = loadCommands.dyldChainedFixups else {
            return nil
        }
        fileHandle.seek(toFileOffset: UInt64(headerStartOffset) + numericCast(info.dataoff))
        let data = fileHandle.readData(ofLength: numericCast(info.datasize))

        return .init(
            data: data,
            isSwapped: isSwapped
        )
    }
}
