//
//  MachOImage.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

/// Structure for `MachO` representation loaded from memory.
///
/// ## Example
/// - Initialize with pointer
/// ``` swift
/// let mh = _dyld_get_image_header(0)!
/// let machO = MachOImage(ptr: mh)
/// ```
/// - Initialize with name
/// ``` swift
/// let machO = MachOImage(name: "Foundation")!
/// ```
///
/// ## SeeAlso
/// For loading MachO files, use ``MachOFile``.
public struct MachOImage: MachORepresentable {
    /// Address of MachO header start
    public let ptr: UnsafeRawPointer

    /// A boolean value that indicates whether the target CPU architecture is 64-bit or not.
    public let is64Bit: Bool

    /// Size of mach header.
    ///
    /// The size of either `mach_header` or `mach_header_64`
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

    /// Initialized with the start pointer of mach header.
    /// - Parameter ptr: start pointer of mach header
    ///
    /// Using function named `_dyld_get_image_header`,  start pointer to the mach header can be obtained.
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
    /// initialize with machO image name.
    /// - Parameter name: name of machO image
    ///
    /// Example.
    /// - /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
    ///     → Foundation
    /// - /usr/lib/swift/libswiftFoundation.dylib
    ///     → libswiftFoundation
    public init?(name: String) {
        #if canImport(Darwin)
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
            return imageName == name
        }

        if let index, let mh = _dyld_get_image_header(index) {
            self.init(ptr: mh)
        } else {
            return nil
        }
        #else
        return nil
        #endif
    }
}

extension MachOImage {
    /// Path name of machO image.
    ///
    /// It is the same value that can be obtained by `Dl_info.dli_fname` or `_dyld_get_image_name`.
    public var path: String? {
        #if canImport(Darwin)
        var info = Dl_info()
        dladdr(ptr, &info)
        return String(cString: info.dli_fname)
        #else
        return nil
        #endif
    }

    /// virtual memory address slide of machO image.
    ///
    /// It is the same value that can be obtained by `_dyld_get_image_vmaddr_slide`.
    ///
    /// [Reference of implementation]( https://github.com/apple-oss-distributions/dyld/blob/d1a0f6869ece370913a3f749617e457f3b4cd7c4/mach_o/Header.cpp#L1354)
    public var vmaddrSlide: Int? {
        let ptr = Int(bitPattern: ptr)
        if let text = loadCommands.text64 {
            return ptr - numericCast(text.vmaddr)
        } else if let text = loadCommands.text {
            return ptr - numericCast(text.vmaddr)
        }
        return nil
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
    public var dependencies: [DependedDylib] {
        var dependencies = [DependedDylib]()
        for cmd in loadCommands {
            switch cmd {
            case let .loadDylib(cmd):
                var flags: DylibUseFlags = []
                if let dylibUseCmd = cmd.dylibUseCommand(in: self) {
                    flags = dylibUseCmd.flags
                }
                let lib = cmd.dylib(cmdsStart: cmdsStartPtr)
                dependencies.append(.init(dylib: lib, type: .load, useFlags: flags))
            case let .loadWeakDylib(cmd):
                var flags: DylibUseFlags = []
                if let dylibUseCmd = cmd.dylibUseCommand(in: self) {
                    flags = dylibUseCmd.flags
                }
                let lib = cmd.dylib(cmdsStart: cmdsStartPtr)
                dependencies.append(.init(dylib: lib, type: .load, useFlags: flags))
            case let .reexportDylib(cmd):
                let lib = cmd.dylib(cmdsStart: cmdsStartPtr)
                dependencies.append(.init(dylib: lib, type: .reexport))
            case let .loadUpwardDylib(cmd):
                let lib = cmd.dylib(cmdsStart: cmdsStartPtr)
                dependencies.append(.init(dylib: lib, type: .upwardLoad))
            case let .lazyLoadDylib(cmd):
                let lib = cmd.dylib(cmdsStart: cmdsStartPtr)
                dependencies.append(.init(dylib: lib, type: .lazyLoad))
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
}

extension MachOImage {
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
        guard let vmaddrSlide else { return nil }
        if is64Bit, let text = loadCommands.text64 {
            let cstrings = text.sections(cmdsStart: cmdsStartPtr).first {
                $0.sectionName == "__cstring"
            }
            guard let cstrings else { return nil }
            return cstrings.strings(vmaddrSlide: vmaddrSlide)
        } else if let text = loadCommands.text {
            let cstrings = text.sections(cmdsStart: cmdsStartPtr).first {
                $0.sectionName == "__cstring"
            }
            guard let cstrings else { return nil }
            return cstrings.strings(vmaddrSlide: vmaddrSlide)
        }
        return nil
    }

    public var allCStringTables: [Strings] {
        guard let vmaddrSlide else { return [] }
        if is64Bit {
            let segments = loadCommands.infos(of: LoadCommand.segment64)
            return segments.flatMap { segment in
                segment.sections(cmdsStart: cmdsStartPtr)
                    .compactMap { section in
                        section.strings(vmaddrSlide: vmaddrSlide)
                    }
            }
        } else {
            let segments = loadCommands.infos(of: LoadCommand.segment)
            return segments.flatMap { segment in
                segment.sections(cmdsStart: cmdsStartPtr)
                    .compactMap { section in
                        section.strings(vmaddrSlide: vmaddrSlide)
                    }
            }
        }
    }

    /// All strings in `__TEXT` segment
    public var allCStrings: [String] {
        allCStringTables.flatMap { $0.map(\.string) }
    }

    public var uStrings: UTF16Strings? {
        guard let vmaddrSlide else { return nil }
        guard let section = sections64.first(where: {
            $0.sectionName == "__ustring"
        }) else { return nil }

        guard let start = section.startPtr(vmaddrSlide: vmaddrSlide) else {
            return nil
        }

        return .init(
            basePointer: start
                .assumingMemoryBound(to: UInt16.self),
            tableSize: numericCast(section.size)
        )
    }
}

extension MachOImage {
    public var rebaseOperations: RebaseOperations? {
        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)

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
        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)

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
        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)

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
        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)

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
    public var exportTrie: ExportTrie? {
        let ldVersion: Version? = {
            loadCommands.info(of: LoadCommand.buildVersion)?
                .tools(cmdsStart: cmdsStartPtr)
                .first(where: { $0.tool == .ld })?
                .version
        }()

        let info = loadCommands.info(of: LoadCommand.dyldInfo) ?? loadCommands.info(of: LoadCommand.dyldInfoOnly)

        if let info {
            if is64Bit,
               let text = loadCommands.text64,
               let linkedit = loadCommands.linkedit64 {
                return ExportTrie(
                    ptr: ptr,
                    text: text,
                    linkedit: linkedit,
                    info: info.layout,
                    ldVersion: ldVersion
                )
            } else if let text = loadCommands.text,
                      let linkedit = loadCommands.linkedit {
                return ExportTrie(
                    ptr: ptr,
                    text: text,
                    linkedit: linkedit,
                    info: info.layout,
                    ldVersion: ldVersion
                )
            }
        }

        guard let export = loadCommands.info(of: LoadCommand.dyldExportsTrie),
              let vmaddrSlide else {
            return nil
        }

        if is64Bit,
           let linkedit = loadCommands.linkedit64 {
            return ExportTrie(
                linkedit: linkedit,
                export: export.layout,
                vmaddrSlide: vmaddrSlide,
                ldVersion: ldVersion
            )
        } else if let linkedit = loadCommands.linkedit {
            return ExportTrie(
                linkedit: linkedit,
                export: export.layout,
                vmaddrSlide: vmaddrSlide,
                ldVersion: ldVersion
            )
        }
        return nil
    }

    public var exportedSymbols: [ExportedSymbol] {
        guard let exportTrie else {
            return []
        }
        return exportTrie.exportedSymbols
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
    ///   - isGlobalOnly: If true, search only global symbols.
    /// - Returns: Closest symbol.
    public func closestSymbol(
        at address: UnsafeRawPointer,
        inSection sectionNumber: Int = 0,
        isGlobalOnly: Bool = false
    ) -> Symbol? {
        let offset = Int(bitPattern: address) - Int(bitPattern: ptr)
        return closestSymbol(
            at: offset,
            inSection: sectionNumber,
            isGlobalOnly: isGlobalOnly
        )
    }
    /// Find the symbols closest to the address at the specified offset.
    ///
    /// Different from ``closestSymbol(at:inSection:isGlobalOnly:)`` multiple symbols with the same offset may be found.
    ///
    /// - Parameters:
    ///   - address: Address to find closest symbol.
    ///   - sectionNumber: Section number to be searched.
    ///   - isGlobalOnly: If true, search only global symbols.
    /// - Returns: Closest symbols.
    func closestSymbols(
        at address: UnsafeRawPointer,
        inSection sectionNumber: Int = 0,
        isGlobalOnly: Bool = false
    ) -> [Symbol] {
        let offset = Int(bitPattern: address) - Int(bitPattern: ptr)
        return closestSymbols(
            at: offset,
            inSection: sectionNumber,
            isGlobalOnly: isGlobalOnly
        )
    }

    /// Find symbols matching the specified address.
    /// - Parameters:
    ///   - address: Address to find matching symbol.
    ///   - isGlobalOnly: If true, search only global symbols.
    /// - Returns: Matched symbol
    public func symbol(
        for address: UnsafeRawPointer,
        isGlobalOnly: Bool = false
    ) -> Symbol? {
        let offset = Int(bitPattern: address) - Int(bitPattern: ptr)
        return symbol(for: offset, isGlobalOnly: isGlobalOnly)
    }

    /// Find the symbols matching the specified offset.
    ///
    /// Different from ``symbol(for:isGlobalOnly:)`` multiple symbols with the same offset may be found.
    ///
    /// - Parameters:
    ///   - address: Address to find matching symbol.
    ///   - isGlobalOnly: If true, search only global symbols.
    /// - Returns: Matched symbols
    func symbols(
        for address: UnsafeRawPointer,
        isGlobalOnly: Bool = false
    ) -> [Symbol] {
        let offset = Int(bitPattern: address) - Int(bitPattern: ptr)
        return symbols(for: offset, isGlobalOnly: isGlobalOnly)
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

        guard let linkeditStartPtr = linkedit.startPtr(
            vmaddrSlide: vmaddrSlide
        ) else {
            return nil
        }

        let start = linkeditStartPtr
            .advanced(by: -numericCast(linkedit.fileoff))
            .advanced(by: numericCast(dataInCode.dataoff))
            .assumingMemoryBound(to: DataInCodeEntry.self)
        let size: Int = numericCast(dataInCode.datasize) / MemoryLayout<DataInCodeEntry>.size

        return .init(basePointer: start, numberOfElements: size)
    }
}

extension MachOImage {
    public var dyldChainedFixups: DyldChainedFixups? {
        guard let vmaddrSlide,
              let chainedFixups = loadCommands.dyldChainedFixups,
              chainedFixups.datasize > 0 else {
            return nil
        }

        if let linkedit = loadCommands.linkedit64 {
            return .init(
                dyldChainedFixups: chainedFixups.layout,
                linkedit: linkedit,
                vmaddrSlide: vmaddrSlide
            )
        } else if let linkedit = loadCommands.linkedit {
            return .init(
                dyldChainedFixups: chainedFixups.layout,
                linkedit: linkedit,
                vmaddrSlide: vmaddrSlide
            )
        }
        return nil
    }
}

extension MachOImage {
    public var externalRelocations: MemorySequence<Relocation>? {
        guard let dysymtab = loadCommands.dysymtab else { return nil }

        let linkedit: (any SegmentCommandProtocol)? = loadCommands.linkedit64 ?? loadCommands.linkedit

        guard let linkedit,
              let vmaddrSlide,
              let start = linkedit.startPtr(vmaddrSlide: vmaddrSlide) else {
            return nil
        }

        return .init(
            basePointer: start
                .advanced(by: -linkedit.fileOffset)
                .advanced(by: numericCast(dysymtab.extreloff))
                .assumingMemoryBound(to: Relocation.self),
            numberOfElements: numericCast(dysymtab.nextrel)
        )
    }

    public var classicBindingSymbols: [ClassicBindingSymbol]? {
        _classicBindingSymbols(
            addendLoader: { address in
                UnsafeRawPointer(bitPattern: UInt(address))?
                    .assumingMemoryBound(to: Int64.self)
                    .pointee ?? 0
            }
        )
    }
}

extension MachOImage {
    public var codeSign: CodeSign? {
        guard let vmaddrSlide,
              let codeSignature = loadCommands.codeSignature,
              codeSignature.datasize > 0 else {
            return nil
        }

        if let linkedit = loadCommands.linkedit64 {
            return .init(
                codeSignature: codeSignature.layout,
                linkedit: linkedit,
                vmaddrSlide: vmaddrSlide
            )
        } else if let linkedit = loadCommands.linkedit {
            return .init(
                codeSignature: codeSignature.layout,
                linkedit: linkedit,
                vmaddrSlide: vmaddrSlide
            )
        }
        return nil
    }
}

extension MachOImage {
    public var cfStrings64: MemorySequence<CFString64>? {
        guard let section = sections64.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }
        guard let vmaddrSlide else { return nil }

        guard let ptr = section.startPtr(vmaddrSlide: vmaddrSlide) else {
            return nil
        }
        let count = section.size / CFString64.layoutSize

        return .init(
            basePointer: ptr
                .assumingMemoryBound(to: CFString64.self),
            numberOfElements: count
        )
    }

    public var cfStrings32: MemorySequence<CFString32>? {
        guard let section = sections32.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }
        guard let vmaddrSlide else { return nil }

        guard let ptr = section.startPtr(vmaddrSlide: vmaddrSlide) else {
            return nil
        }
        let count = section.size / CFString32.layoutSize

        return .init(
            basePointer: ptr
                .assumingMemoryBound(to: CFString32.self),
            numberOfElements: count
        )
    }
}

extension MachOImage {
    public var embeddedInfoPlist: [String: Any]? {
        func plist(in section: any SectionProtocol) throws -> [String: Any]? {
            guard let vmaddrSlide else { return nil }
            guard let ptr = section.startPtr(vmaddrSlide: vmaddrSlide) else {
                return nil
            }
            let data = Data(bytes: ptr, count: section.size)
            guard let infoPlist = try? PropertyListSerialization.propertyList(
                from: data,
                format: nil
            ) else {
                return nil
            }
            return infoPlist as? [String: Any]
        }

        if let text = loadCommands.text64 {
            guard let __info_plist = text.sections(cmdsStart: cmdsStartPtr).first(
                where: { $0.sectionName == "__info_plist" }
            ) else { return nil }
            return try? plist(in: __info_plist)
        } else if let text = loadCommands.text {
            guard let __info_plist = text.sections(cmdsStart: cmdsStartPtr).first(
                where: { $0.sectionName == "__info_plist" }
            ) else { return nil }
            return try? plist(in: __info_plist)
        }
        return nil
    }
}

extension MachOImage {
    /// Determines whether the specified pointer is contained within any segment of the Mach-O binary.
    ///
    /// - Parameter ptr: The pointer to check.
    /// - Returns: `true` if the address is within any segment; otherwise, `false`.
    public func contains(ptr: UnsafeRawPointer) -> Bool {
        let slide = vmaddrSlide ?? 0
        let address = Int(bitPattern: ptr)

        if slide > address { return false }

        let unslidAddress = address - slide
        return contains(unslidAddress: numericCast(unslidAddress))
    }
}
