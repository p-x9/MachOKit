//
//  MachOImage.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public struct MachOImage: MachORepresentable {
    /// Address of MachO header start
    public let ptr: UnsafeRawPointer

    public let is64Bit: Bool

    public var headerSize: Int {
        is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
    }

    public var header: MachHeader {
        .init(
            layout: ptr
                .assumingMemoryBound(to: mach_header.self)
                .pointee
        )
    }

    public let loadCommands: LoadCommands

    /// Address of load commands list start
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

extension MachOImage {
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

extension MachOImage {
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

extension MachOImage {
    public var rpaths: [String] {
        loadCommands
            .compactMap { cmd in
                if case let .rpath(info) = cmd { info.path(cmdsStart: cmdsStartPtr) } else { nil }
            }
    }
}

extension MachOImage {
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

extension MachOImage {
    public var sections64: [Section64] {
        segments64.map {
            $0.sections(cmdsStart: cmdsStartPtr)
        }.flatMap { $0 }
    }

    public var sections32: [Section] {
        segments32.map {
            $0.sections(cmdsStart: cmdsStartPtr)
        }.flatMap { $0 }
    }
}

extension MachOImage {
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

    public typealias IndirectSymbols = MemorySequence<IndirectSymbol>
    public var indirectSymbols: IndirectSymbols? {
        let fileSlide: Int
        guard let dysymtab = loadCommands.dysymtab else { return nil }

        if let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64 {
            fileSlide = numericCast(linkedit.vmaddr) - numericCast(text.vmaddr) - numericCast(linkedit.fileoff)
        } else if let text = loadCommands.text,
                  let linkedit = loadCommands.linkedit {
            fileSlide = numericCast(linkedit.vmaddr) - numericCast(text.vmaddr) - numericCast(linkedit.fileoff)
        } else {
            return nil
        }

        return .init(
            basePointer: ptr
                .advanced(
                    by: fileSlide + numericCast(dysymtab.indirectsymoff)
                )
                .assumingMemoryBound(to: IndirectSymbol.self),
            numberOfElements: numericCast(dysymtab.nindirectsyms)
        )
    }
}

extension MachOImage {
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

extension MachOImage {
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

    public var allCStringTables: [Strings] {
        let sections: [any SectionProtocol]
        if is64Bit {
            let segments = loadCommands.infos(of: LoadCommand.segment64)
            sections = segments.flatMap {
                $0.sections(cmdsStart: cmdsStartPtr)
            }
        } else {
            let segments = loadCommands.infos(of: LoadCommand.segment)
            sections = segments.flatMap {
                $0.sections(cmdsStart: cmdsStartPtr)
            }
        }

        return sections.reduce(into: []) { partialResult, section in
            if let strings = section.strings(ptr: ptr) {
                partialResult += [strings]
            }
        }
    }

    /// All strings in `__TEXT` segment
    public var allCStrings: [String] {
        allCStringTables.flatMap { $0.map(\.string) }
    }
}

extension MachOImage {
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

extension MachOImage {
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

extension MachOImage {
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

extension MachOImage {
    /// Find the symbol closest to the address.
    ///
    /// Behaves almost identically to the `dladdr` function
    ///
    /// - Parameters:
    ///   - address: Address to find closest symbol.
    ///   - sectionNumber: Section number to be searched.
    /// - Returns: Closest symbol.
    public func closestSymbol(
        at address: UnsafeRawPointer,
        inSection sectionNumber: Int = 0
    ) -> Symbol? {
        let offset = Int(bitPattern: address) - Int(bitPattern: ptr)
        return closestSymbol(
            at: offset,
            inSection: sectionNumber
        )
    }

    /// Find symbols matching the specified address.
    /// - Parameter address: Address to find matching symbol.
    /// - Returns: Matched symbol
    func symbol(for address: UnsafeRawPointer) -> Symbol? {
        let offset = Int(bitPattern: address) - Int(bitPattern: ptr)
        return symbol(for: offset)
    }
}

extension MachOImage {
    public var functionStarts: FunctionStarts? {
        guard let vmaddrSlide,
              let functionStarts = loadCommands.functionStarts,
              functionStarts.datasize > 0 else {
            return nil
        }

        if let linkedit = loadCommands.linkedit64,
           let text = loadCommands.text64 {
            return .init(
                functionStarts: functionStarts.layout,
                linkedit: linkedit,
                text: text,
                vmaddrSlide: vmaddrSlide
            )
        } else if let linkedit = loadCommands.linkedit,
                  let text = loadCommands.text {
            return .init(
                functionStarts: functionStarts.layout,
                linkedit: linkedit,
                text: text,
                vmaddrSlide: vmaddrSlide
            )
        }
        return nil
    }
}

extension MachOImage {
    public var dataInCode: MemorySequence<DataInCodeEntry>? {
        guard let vmaddrSlide,
              let dataInCode = loadCommands.dataInCode,
              let linkedit = loadCommands.linkedit64,
              dataInCode.datasize > 0 else {
            return nil
        }

        var linkeditStart = vmaddrSlide
        linkeditStart += numericCast(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        guard let linkeditStartPtr = UnsafeRawPointer(bitPattern: linkeditStart) else {
            return nil
        }

        let start = linkeditStartPtr
            .advanced(by: numericCast(dataInCode.dataoff))
            .assumingMemoryBound(to: DataInCodeEntry.self)
        let size: Int = numericCast(dataInCode.datasize) / MemoryLayout<DataInCodeEntry>.size

        return .init(basePointer: start, numberOfElements: size)
    }
}
