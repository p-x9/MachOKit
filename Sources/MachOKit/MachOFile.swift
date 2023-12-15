//
//  MachOFile.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public class MachOFile: MachORepresentable {
    public let url: URL
    let fileHandle: FileHandle

    public private(set) var isSwapped: Bool

    public var is64Bit: Bool { header.magic.is64BitMach }
    public var headerSize: Int {
        is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
    }

    public let header: MachHeader

    public let headerStartOffset: Int
    public var cmdsStartOffset: Int {
        headerStartOffset + headerSize
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

    public init(url: URL, headerStartOffset: Int = 0) throws {
        self.url = url
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle

        self.headerStartOffset = headerStartOffset
        fileHandle.seek(toFileOffset: UInt64(headerStartOffset))

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
        if let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64,
           let symtab = loadCommands.symtab {
            return Symbols64(
                machO: self,
                text: text,
                linkedit: linkedit,
                symtab: symtab
            )
        }
        return nil
    }

    public var symbols32: Symbols? {
        guard !is64Bit else {
            return nil
        }
        if let text = loadCommands.text,
           let linkedit = loadCommands.linkedit,
           let symtab = loadCommands.symtab {
            return Symbols(
                machO: self,
                text: text,
                linkedit: linkedit,
                symtab: symtab
            )
        }
        return nil
    }
}

extension MachOFile {
    public var symbolStrings: Strings? {
        if let symtab = loadCommands.symtab {
            fileHandle.seek(toFileOffset: UInt64(headerStartOffset) + UInt64(symtab.stroff))
            let data = fileHandle.readData(ofLength: Int(symtab.strsize))
            return Strings(
                data: data
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

        if is64Bit,
           let linkedit = loadCommands.linkedit64 {
            return ExportTrieEntries(
                machO: self,
                linkedit: linkedit,
                export: export.layout
            )
        } else if let linkedit = loadCommands.linkedit {
            return ExportTrieEntries(
                machO: self,
                linkedit: linkedit,
                export: export.layout
            )
        }
        return nil
    }
}
