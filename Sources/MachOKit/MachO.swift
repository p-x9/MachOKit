//
//  MachO.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public struct MachO {
    public let ptr: UnsafeRawPointer

    public let is64Bit: Bool
    public let loadCommands: LoadCommands

    public var headerSize: Int {
        is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
    }

    public var cmdsStartPtr: UnsafeRawPointer {
        ptr.advanced(by: headerSize)
    }

    public init(ptr: UnsafePointer<mach_header>) {
        self.ptr = .init(ptr)

        let header = ptr.pointee

        self.is64Bit = header.magic == MH_MAGIC_64 || header.magic == MH_CIGAM_64
        let start = UnsafeRawPointer(ptr)
            .advanced(
                by: is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
            )
        loadCommands = .init(start: start, numberOfCommands: Int(header.ncmds))
    }
}

extension MachO {
    public init?(name: String) {
        let indices = 0..<_dyld_image_count()
        let index = indices.first { index in
            guard let pathC = _dyld_get_image_name(index) else {
                return false
            }
            let path = String(cString: pathC)
            let imageName = path
                .components(separatedBy: "/")
                .last?
                .components(separatedBy: ".")
                .first
            if imageName == name {
                print(path)
            }
            return imageName == name
        }

        if let index, let mh = _dyld_get_image_header(index) {
            self.init(ptr: mh)
        } else {
            return nil
        }
    }
}

extension MachO {
    public var header: MachHeader {
        .init(
            layout: ptr
                .assumingMemoryBound(to: mach_header.self)
                .pointee
        )
    }
}

extension MachO {
    public var path: String? {
        var info = Dl_info()
        dladdr(ptr, &info)
        return String(cString: info.dli_fname)
    }

    public var vmaddrSlide: Int? {
        guard self.path != nil else { return nil }

        let indices = 0..<_dyld_image_count()
        let index = indices.first { index in
            guard let pathC = _dyld_get_image_name(index) else {
                return false
            }
            let path = String(cString: pathC)
            return path == self.path
        }

        return _dyld_get_image_vmaddr_slide(index ?? 0)
    }
}

extension MachO {
    public var symbols: AnySequence<Symbol> {
        if is64Bit, let symbols64 {
            AnySequence(symbols64)
        } else if let symbols32 {
            AnySequence(symbols32)
        } else {
            AnySequence([])
        }
    }

    public var symbols64: Symbols64? {
        guard is64Bit else {
            return nil
        }
        if let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64,
           let symtab = loadCommands.symtab {
            return Symbols64(ptr: ptr, text: text, linkedit: linkedit, symtab: symtab)
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
            return Symbols(ptr: ptr, text: text, linkedit: linkedit, symtab: symtab)
        }
        return nil
    }
}

extension MachO {
    public var symbolStrings: Strings? {
        if is64Bit,
           let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64,
           let symtab = loadCommands.symtab {
            return Strings(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                symtab: symtab
            )
        } else if let text = loadCommands.text,
                  let linkedit = loadCommands.linkedit,
                  let symtab = loadCommands.symtab {
            return Strings(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                symtab: symtab
            )
        }
        return nil
    }
}

extension MachO {
    public var rebaseOperations: RebaseOperations? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first

        guard let info else { return nil }

        if is64Bit,
           let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64 {
            return RebaseOperations(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                info: info.layout
            )
        } else if let text = loadCommands.text,
                  let linkedit = loadCommands.linkedit {
            return RebaseOperations(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                info: info.layout
            )
        }
        return nil
    }
}

extension MachO {
    public var bindOperations: BindOperations? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first

        guard let info else { return nil }

        if is64Bit,
           let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64 {
            return BindOperations(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                info: info.layout
            )
        } else if let text = loadCommands.text,
                  let linkedit = loadCommands.linkedit {
            return BindOperations(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                info: info.layout
            )
        }
        return nil
    }

    public var weakBindOperations: BindOperations? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first

        guard let info else { return nil }

        if is64Bit,
           let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64 {
            return BindOperations(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                info: info.layout,
                kind: .weak
            )
        } else if let text = loadCommands.text,
                  let linkedit = loadCommands.linkedit {
            return BindOperations(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                info: info.layout,
                kind: .weak
            )
        }
        return nil
    }

    public var lazyBindOperations: BindOperations? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first

        guard let info else { return nil }

        if is64Bit,
           let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64 {
            return BindOperations(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                info: info.layout,
                kind: .lazy
            )
        } else if let text = loadCommands.text,
                  let linkedit = loadCommands.linkedit {
            return BindOperations(
                ptr: ptr,
                text: text,
                linkedit: linkedit,
                info: info.layout,
                kind: .lazy
            )
        }
        return nil
    }
}

extension MachO {
    public var exportTrieEntries: ExportTrieEntries? {
        let info = Array(loadCommands.infos(of: LoadCommand.dyldInfo)).first ?? Array(loadCommands.infos(of: LoadCommand.dyldInfoOnly)).first

        if let info {
            if is64Bit,
               let text = loadCommands.text64,
               let linkedit = loadCommands.linkedit64 {
                return ExportTrieEntries(
                    ptr: ptr,
                    text: text,
                    linkedit: linkedit,
                    info: info.layout
                )
            } else if let text = loadCommands.text,
                      let linkedit = loadCommands.linkedit {
                return ExportTrieEntries(
                    ptr: ptr,
                    text: text,
                    linkedit: linkedit,
                    info: info.layout
                )
            }
        }

        guard let export = Array(loadCommands.infos(of: LoadCommand.dyldExportsTrie)).first,
              let vmaddrSlide else {
            return nil
        }

        if is64Bit,
           let linkedit = loadCommands.linkedit64 {
            return ExportTrieEntries(
                linkedit: linkedit,
                export: export.layout,
                vmaddrSlide: vmaddrSlide
            )
        } else if let linkedit = loadCommands.linkedit {
            return ExportTrieEntries(
                linkedit: linkedit,
                export: export.layout,
                vmaddrSlide: vmaddrSlide
            )
        }

        return nil
    }
}

extension MachO {
    public var rpaths: [String] {
        loadCommands
            .compactMap { cmd in
                if case let .rpath(info) = cmd { info.path(cmdsStart: cmdsStartPtr) } else { nil }
            }
    }
}

extension MachO {
    /// Strings in `__TEXT, __cstring` section
    public var cStrings: Strings? {
        if is64Bit, let text = loadCommands.text64 {
            let cstrings = text.sections(cmdsStart: cmdsStartPtr).filter {
                $0.sectionName == "__cstring"
            }.first
            guard let cstrings else { return nil }
            return cstrings.strings(ptr: ptr)
        } else if let text = loadCommands.text {
            let cstrings = text.sections(cmdsStart: cmdsStartPtr).filter {
                $0.sectionName == "__cstring"
            }.first
            guard let cstrings else { return nil }
            return cstrings.strings(ptr: ptr)
        }
        return nil
    }

    /// All strings in `__TEXT` segment
    public var allCStrings: [String] {
        let sections: [any SectionProtocol]
        if is64Bit {
            let segments = loadCommands.infos(of: LoadCommand.segment64)
            sections = segments.reduce(into: []) { partialResult, segment in
                partialResult += Array(segment.sections(cmdsStart: cmdsStartPtr))
            }
        } else {
            let segments = loadCommands.infos(of: LoadCommand.segment)
            sections = segments.reduce(into: []) { partialResult, segment in
                partialResult += Array(segment.sections(cmdsStart: cmdsStartPtr))
            }
        }

        return sections.reduce(into: []) { partialResult, section in
            if let strings = section.strings(ptr: ptr) {
                partialResult += Array(strings).map(\.string)
            }
        }
    }
}

extension MachO {
    public var exportedSymbols: [ExportedSymbol] {
        guard let exportTrieEntries else {
            return []
        }
        return exportTrieEntries.exportedSymbols
    }
}

extension MachO {
    public var dependencies: [Dylib] {
        var dependencies = [Dylib]()
        for cmd in loadCommands {
            switch cmd {
            case let .loadDylib(cmd): dependencies.append(cmd.dylib(cmdsStart: cmdsStartPtr))
            case let .loadWeakDylib(cmd): dependencies.append(cmd.dylib(cmdsStart: cmdsStartPtr))
            case let .reexportDylib(cmd): dependencies.append(cmd.dylib(cmdsStart: cmdsStartPtr))
            case let .loadUpwardDylib(cmd): dependencies.append(cmd.dylib(cmdsStart: cmdsStartPtr))
            case let .lazyLoadDylib(cmd): dependencies.append(cmd.dylib(cmdsStart: cmdsStartPtr))
            default: continue
            }
        }
        return dependencies
    }
}
