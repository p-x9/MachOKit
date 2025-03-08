//
//  MachOFilePrintTests.swift
//
//
//  Created by p-x9 on 2023/12/17.
//  
//

import XCTest
@testable import MachOKit

final class MachOFilePrintTests: XCTestCase {

    private var fat: FatFile!
    private var machO: MachOFile!

    override func setUp() {
        print("----------------------------------------------------")
//        let path = "/System/Applications/Calculator.app/Contents/MacOS/Calculator"
        let path = "/System/Applications/Freeform.app/Contents/MacOS/Freeform"
        let url = URL(fileURLWithPath: path)
        guard let file = try? MachOKit.loadFromFile(url: url) else {
            XCTFail("Failed to load file")
            return
        }
        switch file {
        case let .fat(fatFile):
            self.fat = fatFile
            self.machO = try! fatFile.machOFiles()[0]
        case let .machO(machO):
            self.machO = machO
        }

    }

    func testHeader() throws {
        print("Magic:", fat.header.magic!)
        print("isSwapped:", fat.isSwapped)
        print("Arches", fat.arches.compactMap(\.cpuType))

        let machOs = try fat.machOFiles()
        for machO in machOs {
            let header = machO.header
            print("----")
            print("Magic:", header.magic!)
            print("isSwapped:", machO.isSwapped)
            print("CPU:", header.cpu)
            print("FileType:", header.fileType?.description ?? "unknown")
            print("Flags:", header.flags.bits.map(\.description).joined(separator: ", "))
        }
    }

    func testLoadCommands() throws {
        for command in machO.loadCommands {
            print("----")
            print(command.type)
            print(command.info)
        }
    }

    func testSegments() throws {
        for segment in machO.segments {
            print("----")
            print("Name:", segment.segmentName)
            print(
                "InitProt:",
                segment.initialProtection.bits
                    .map(\.description)
                    .joined(separator: ", ")
            )
            print(
                "MaxProt:",
                segment.maxProtection.bits
                    .map(\.description)
                    .joined(separator: ", ")
            )
            if !segment.flags.bits.isEmpty {
                print(
                    "Flags:",
                    segment.flags.bits
                        .map(\.description)
                        .joined(separator: ", ")
                )
            }
        }
    }

    func testSections() throws {
        for section in machO.sections {
            print("----")
            print("Name:", "\(section.segmentName).\(section.sectionName)")
            print("Type:", section.flags.type?.description ?? "unknown")
            print(
                "Attributes:",
                section.flags.attributes.bits
                    .map(\.description).joined(separator: ", ")
            )
        }
    }

    func testSectionRelocationInfos() {
        let symbols = machO.symbols
        for section in machO.sections32 where section.nreloc > 0 {
            print("----")
            print("Name:", "\(section.segmentName).\(section.sectionName)"
            )
            let relocations = section.relocations(in: machO)
            for relocation in relocations {
                print("--")
                switch relocation.info {
                case let .general(info):
                    print("Offset:", "0x" + String(info.r_address, radix: 16))
                    if let length = info.length {
                        print("Length:", length)
                    }
                    print("isExternal:", info.isExternal)
                    print("isScatted:", info.isScattered)
                    print("pcRelative:", info.isRelocatedPCRelative)
                    if let symbolIndex = info.symbolIndex {
                        print("SymbolIndex:", symbolIndex)
                        print("SymbolName:", symbols[AnyIndex(symbolIndex)].name)
                    }
                    if let sectionOrdinal = info.sectionOrdinal {
                        print("SectionOrdinal:", sectionOrdinal)
                    }
                    if let cpuType = machO.header.cpuType,
                       let type = info.type(for: cpuType) {
                        print("Type:", type)
                    }
                case let .scattered(info):
                    print("Offset:", "0x" + String(info.layout.r_address, radix: 16))
                    if let length = info.length {
                        print("Length:", length)
                    }
                    print("isScatted:", info.isScattered)
                    print("pcRelative:", info.isRelocatedPCRelative)
                    if let cpuType = machO.header.cpuType,
                       let type = info.type(for: cpuType) {
                        print("Type:", type)
                    }
                    print("Value:", "0x" + String(info.r_value, radix: 16))
                }
            }
        }
    }

    func testExternalRelocations() {
        guard let relocations = machO.externalRelocations else {
            return
        }
        let symbols = machO.symbols
        for relocation in relocations {
            print("--")
            switch relocation.info {
            case let .general(info):
                print("Offset:", "0x" + String(info.r_address, radix: 16))
                if let length = info.length {
                    print("Length:", length)
                }
                print("isExternal:", info.isExternal)
                print("isScatted:", info.isScattered)
                print("pcRelative:", info.isRelocatedPCRelative)
                if let symbolIndex = info.symbolIndex {
                    print("SymbolIndex:", symbolIndex)
                    print("SymbolName:", symbols[AnyIndex(symbolIndex)].name)
                }
                if let sectionOrdinal = info.sectionOrdinal {
                    print("SectionOrdinal:", sectionOrdinal)
                }
                if let cpuType = machO.header.cpuType,
                   let type = info.type(for: cpuType) {
                    print("Type:", type)
                }
            case let .scattered(info):
                print("Offset:", "0x" + String(info.layout.r_address, radix: 16))
                if let length = info.length {
                    print("Length:", length)
                }
                print("isScatted:", info.isScattered)
                print("pcRelative:", info.isRelocatedPCRelative)
                if let cpuType = machO.header.cpuType,
                   let type = info.type(for: cpuType) {
                    print("Type:", type)
                }
                print("Value:", "0x" + String(info.r_value, radix: 16))
            }
        }
    }

    func testClassicBindingSymbols() throws {
        guard let bindingSymbols = machO.classicBindingSymbols else {
            return
        }
        let symbols = machO.symbols

        for bindingSymbol in bindingSymbols {
            print("--")
            let symbol = symbols[AnyIndex(bindingSymbol.symbolIndex)]
            print("Address:", "0x" + String(bindingSymbol.address, radix: 16))
            print("Type:", bindingSymbol.type)
            print("Name:", symbol.name)
            print("Addend:", "0x" + String(bindingSymbol.addend, radix: 16))
        }
    }

    func testClassicLazyBindingSymbols() throws {
        guard let bindingSymbols = machO.classicLazyBindingSymbols else {
            return
        }
        let symbols = machO.symbols

        for bindingSymbol in bindingSymbols {
            print("--")
            let symbol = symbols[AnyIndex(bindingSymbol.symbolIndex)]
            print("Address:", "0x" + String(bindingSymbol.address, radix: 16))
            print("Type:", bindingSymbol.type)
            print("Name:", symbol.name)
            print("Addend:", "0x" + String(bindingSymbol.addend, radix: 16))
        }
    }

    func testDependencies() throws {
        for dependency in machO.dependencies {
            let dylib = dependency.dylib
            print("----")
            print("Name:", dylib.name)
            print("CurrentVersion:", dylib.currentVersion)
            print("CompatibilityVersion:", dylib.compatibilityVersion)
            print("TimeStamp:", dylib.timestamp)
            if dependency.dylib.isFromDylibUseCommand {
                print("Flags", dependency.useFlags.bits)
            }
        }
    }

    func testRPaths() throws {
        for rpath in machO.rpaths {
            print(rpath)
        }
    }

    func testSymbols() throws {
        for symbol in machO.symbols {
            print("----")
            print("0x" + String(symbol.offset, radix: 16), symbol.name)
            if let flags = symbol.nlist.flags {
                print("Flags:", flags.bits)
                if let type = flags.type {
                    print("Type:", type)
                }
                if let stab = flags.stab {
                    print("Stab:", stab)
                }
            }
            if let sectionNumber = symbol.nlist.sectionNumber {
                let section = machO.sections[sectionNumber - 1]
                print("Section:", "\(section.segmentName).\(section.sectionName)")
            }
            if let description = symbol.nlist.symbolDescription {
                print("SymbolDescription:", description.bits)
                if let referenceFlag = description.referenceFlag {
                    print("ReferenceFlag:", referenceFlag)
                }
                let libraryOrdinal = Int(description.libraryOrdinal) - 1
                if libraryOrdinal == -1,
                   let info = machO.loadCommands.info(of: LoadCommand.idDylib) {
                    print("LibraryOrdinal:", info.dylib(in: machO).name)
                } else if machO.dependencies.indices.contains(libraryOrdinal) {
                    print("LibraryOrdinal:", machO.dependencies[libraryOrdinal].dylib.name)
                }
            }
        }
    }

    func testIndirectSymbols() throws {
        guard let _indirectSymbols = machO.indirectSymbols else { return }
        let symbols = machO.symbols
        let indirectSymbols = Array(_indirectSymbols)

        for section in machO.sections {
            guard let index = section.indirectSymbolIndex,
                  let size = section.numberOfIndirectSymbols else {
                continue
            }
            print(section.segmentName + "." + section.sectionName)

            let indirectSymbols = indirectSymbols[index..<index + size]
            for symbol in indirectSymbols {
                print(" ", symbol._value, terminator: " ")
                if let index = symbol.index {
                    print(symbols[AnyIndex(index)].name)
                } else {
                    print(symbol)
                }
            }
        }
    }

    func testSymbolStrings() throws {
        guard let cstrings = machO.symbolStrings else { return }
        for (i, cstring) in cstrings.enumerated() {
            let offset = cstrings.offset + cstring.offset - machO.headerStartOffset
            print(i, "0x" + String(offset, radix: 16), cstring.string, stdlib_demangleName(cstring.string))
        }
    }

    func testCStrings() throws {
        guard let cstrings = machO.cStrings else { return }
        for (i, cstring) in cstrings.enumerated() {
            let offset = cstrings.offset + cstring.offset - machO.headerStartOffset
            print(i, "0x" + String(offset, radix: 16), cstring.string)
        }
    }

    func testAllCStrings() throws {
        for (i, cstring) in machO.allCStrings.enumerated() {
            print(i, cstring)
        }
    }

    func testUStrings() throws {
        guard let cstrings = machO.uStrings else { return }
        for (i, cstring) in cstrings.enumerated() {
            let offset = cstrings.offset + cstring.offset - machO.headerStartOffset
            print(i, "0x" + String(offset, radix: 16), cstring.string)
        }
    }

    func testCFStrings() {
        guard let cfStrings = machO.cfStrings else { return }
        for (i, cfString) in cfStrings.enumerated() {
            let string = cfString.string(in: machO) ?? ""
            let type = cfString.isUnicode ? "Unicode" : "8-bit"
            print(i, type, cfString.stringSize, string)
        }
    }
}

extension MachOFilePrintTests {
    func testRebaseOperations() throws {
        guard let rebaseOperations = machO.rebaseOperations else { return }
        for operation in rebaseOperations {
            print(operation)
        }
    }

    func testBindOperations() throws {
        guard let bindOperations = machO.bindOperations else { return }
        for operation in bindOperations {
            print(operation)
        }
    }

    func testWeakBindOperations() throws {
        guard let bindOperations = machO.weakBindOperations else { return }
        for operation in bindOperations {
            print(operation)
        }
    }

    func testLazyBindOperations() throws {
        guard let bindOperations = machO.lazyBindOperations else { return }
        for operation in bindOperations {
            print(operation)
        }
    }

    func testExportTries() throws {
        guard let exportTrie = machO.exportTrie else { return }
        for entry in exportTrie.entries {
            print(entry)
        }
    }
}

extension MachOFilePrintTests {
    func testRebases() throws {
        for rebase in machO.rebases {
            guard let segment = rebase.segment64(in: machO),
                  let section = rebase.section64(in: machO),
                  let address = rebase.address(in: machO) else {
                continue
            }
            print(
                segment.segmentName,
                section.sectionName,
                "0x" + String(address, radix: 16).uppercased(),
                rebase.type
            )
        }
    }

    func testBindingSymbols() throws {
        for binding in machO.bindingSymbols {
            guard let segment = binding.segment64(in: machO),
                  let section = binding.section64(in: machO),
                  let address = binding.address(in: machO) else {
                continue
            }
            print(
                segment.segmentName,
                section.sectionName,
                "0x" + String(address, radix: 16).uppercased(),
                binding.type,
                binding.addend,
                binding.library(in: machO)?.name ?? "\(binding.bindSpecial!)",
                binding.symbolName
            )
        }
    }

    func testExportedSymbols() throws {
        for symbol in machO.exportedSymbols {
            print("----")
            print("0x" + String(symbol.offset ?? 0, radix: 16), symbol.name)

            let found = machO.exportTrie?.search(by: symbol.name)
            XCTAssertNotNil(found)
            XCTAssertEqual(found?.offset, symbol.offset)

            print("Flags:", symbol.flags.bits)
            if let kind = symbol.flags.kind {
                print("Kind:", kind)
            }

            if let ordinal = symbol.ordinal {
                let libraryOrdinal = Int(ordinal) - 1
                if libraryOrdinal == -1,
                   let info = machO.loadCommands.info(of: LoadCommand.idDylib) {
                    print("LibraryOrdinal:", info.dylib(in: machO).name)
                } else if machO.dependencies.indices.contains(libraryOrdinal) {
                    print("LibraryOrdinal:", machO.dependencies[libraryOrdinal].dylib.name)
                }
            }

            if let importedName = symbol.importedName {
                print("Imported Name:", importedName)
            }

            if let stub = symbol.stub, let resolver = symbol.resolverOffset {
                print("Stub:", stub)
                print("Resolver:", resolver)
            }
        }
    }
}

extension MachOFilePrintTests {
    func testLoadDylinkerCommand() {
        for info in machO.loadCommands.infos(of: LoadCommand.loadDylinker) {
            print(info.name(in: machO))
        }
    }

    func testVersionMinCommand() {
        // macOS
        for info in machO.loadCommands.infos(of: LoadCommand.versionMinMacosx) {
            print("version: \(info.version), sdk: \(info.sdk)")
        }

        // iOS
        for info in machO.loadCommands.infos(of: LoadCommand.versionMinIphoneos) {
            print("version: \(info.version), sdk: \(info.sdk)")
        }

        // watchOS
        for info in machO.loadCommands.infos(of: LoadCommand.versionMinWatchos) {
            print("version: \(info.version), sdk: \(info.sdk)")
        }

        // tvOS
        for info in machO.loadCommands.infos(of: LoadCommand.versionMinWatchos) {
            print("version: \(info.version), sdk: \(info.sdk)")
        }
    }

    func testBuildVersionCommand() {
        for info in machO.loadCommands.infos(of: LoadCommand.buildVersion) {
            print("----")
            print(info.platform)
            let tools = info.tools(in: machO)
            for tool in Array(tools) {
                print(" ", tool.tool ?? "\(tool.layout.tool)", tool.version)
            }
        }
    }

    func testUUIDCommand() {
        for info in machO.loadCommands.infos(of: LoadCommand.uuid) {
            print(info.uuid)
        }
    }

    func testMainCommand() {
        machO.loadCommands.infos(of: LoadCommand.main)
            .forEach {
                let offset = $0.layout.entryoff
                print("0x" + String(offset, radix: 16))
            }
    }

    func testLinkerOptionCommand() {
        machO.loadCommands.infos(of: LoadCommand.linkerOption)
            .forEach {
                print($0.count, $0.options(in: machO))
            }
    }

    func testThreadCommand() {
        let path = "/cores/core.2627" // has thread command
        let url = URL(fileURLWithPath: path)
        guard let machO = try? MachOFile(url: url) else { return }

        let commands = Array(machO.loadCommands.infos(of: LoadCommand.thread))
        + Array(machO.loadCommands.infos(of: LoadCommand.unixthread))

        let cpuType = machO.header.cpuType!

        for command in commands {
            let flavor = command.flavor(
                in: machO,
                cpuType: cpuType
            )
            print("Flavor:",
                  flavor?.description ?? "unknown"
            )
            print("Count:", command.count(in: machO) ?? 0)
            if let state = command.state(in: machO, cpuType: cpuType) {
                print("State:", state)
            }
        }
    }
}

extension MachOFilePrintTests {
    func testClosestSymbol() {
        for symbol in machO.symbols {
            let offset = symbol.offset + Int.random(in: 0..<100)
            guard let best = machO.closestSymbol(
                at: offset
            ) else {
                continue
            }

            let diff = best.offset - offset

            print(
                offset == best.offset,
                symbol.offset == best.offset,
                symbol.name == best.name,
                symbol.name,
                best.name,
                diff
            )
        }
    }
}

extension MachOFilePrintTests {
    func testFindSymbolByName() {
        let name = "$ss9CodingKeyP9CoherenceAC15IntCaseIterableRzs0eF0RzrlE8intCasesShySiGvgZ"
        let demangledName = "async function pointer to dispatch thunk of Swift.Clock.sleep(until: A.Instant, tolerance: Swift.Optional<A.Duration>) async throws -> ()"

        guard let symbol = machO.symbols(named: name).first else {
            XCTFail("not found symbol named \"\(name)\"")
            return
        }
        print("found", symbol.name)
        XCTAssert(
            name == symbol.name ||
            "_" + name == symbol.name
        )

        guard let symbol2 = machO.symbols(named: demangledName, mangled: false).first else {
            XCTFail("not found symbol named \"\(demangledName)\"")
            return
        }
        print("found", symbol2.name)
        XCTAssert(
            demangledName == symbol2.demangledName
        )
    }
}

extension MachOFilePrintTests {
    func testFunctionStarts() {
        guard let functionStarts = machO.functionStarts else { return }
        let starts = Array(functionStarts)

        var lastOffset: UInt = functionStarts.functionStartBase
        for start in starts {
            print(
                "+\(start.offset - lastOffset)",
                String(start.offset, radix: 16)
            )
            lastOffset = start.offset
        }
    }
}

extension MachOFilePrintTests {
    func testDataInCode() {
        // x86_64 `Foundation`
        if let dataInCode = machO.dataInCode {
            for data in dataInCode {
                print(String(data.offset, radix: 16), data.length, data.kind?.description ?? "unknown")
            }
        }
    }
}

extension MachOFilePrintTests {
    func testChainedFixUps() {
        guard let chainedFixups = machO.dyldChainedFixups else {
            return
        }

        guard let header = chainedFixups.header else { return }
        print("Header:", header.layout)

        guard let startsInImage = chainedFixups.startsInImage else { return }
        print("Image:", startsInImage.layout)

        let segments = chainedFixups.startsInSegments(of: startsInImage)
        for segment in segments {
            print("Segment:", segment.layout)
            let pages = chainedFixups.pages(of: segment)
            print(
                "pages: ",
                "[" +
                pages.map {
                    String($0.offset, radix: 16)
                }.joined(separator: ", ")
                + "]"
            )
        }
    }

    func testChainedFixUpsImports() {
        guard let chainedFixups = machO.dyldChainedFixups else {
            return
        }
        let libraries = machO.dependencies

        let imports = chainedFixups.imports
        for (i, `import`) in imports.enumerated() {
            print("----")
            print("0x" + String(i, radix: 16))
            let info = `import`.info
            if let libraryOrdinalType = info.libraryOrdinalType {
                print("Library:", libraryOrdinalType)
            } else if libraries.indices.contains(info.libraryOrdinal - 1) {
                print("Library:", libraries[info.libraryOrdinal - 1].dylib.name)
            }
            let name = chainedFixups.symbolName(
                for: info.nameOffset
            )
            if let name { print("Name:", name) }
        }
    }

    // xcrun dyld_info -fixups /System/Applications/Freeform.app/Contents/MacOS/Freeform
    func testChainedFixUpPointers() {
        guard let chainedFixups = machO.dyldChainedFixups,
            let startsInImage = chainedFixups.startsInImage else {
            return
        }
        let segments = machO.segments

        let startsInSegments = chainedFixups.startsInSegments(of: startsInImage)
        for (i, startsInSegment) in startsInSegments.enumerated() {
            print("----")
            let segment = segments[i]
            print(segment.segmentName)

            let pointers = chainedFixups.pointers(of: startsInSegment, in: machO)
            let imports = chainedFixups.imports

            for pointer in pointers {
                let fixupInfo = pointer.fixupInfo
                let offset = String(pointer.offset, radix: 16)

                let section = segment.section(
                    at: UInt(pointer.offset - segment.fileOffset),
                    in: machO
                )
                let sectionName = section?.sectionName ?? "unknown"

                if let rebase = fixupInfo.rebase {
                    print(sectionName, offset, "rebase:", String(rebase.target, radix: 16))
                }
                if let bind = fixupInfo.bind {
                    print(sectionName, offset, "bind:", terminator: " ")
                    print(
                        chainedFixups.demangledSymbolName(for: imports[bind.ordinal].info.nameOffset) ?? ""
                    )
                }
            }
        }
    }
}

extension MachOFilePrintTests {
    func testCodeSign() {
        guard let codeSign = machO.codeSign else {
            return
        }
        guard let superBlob = codeSign.superBlob else {
            return
        }
        let indices = superBlob.blobIndices(in: codeSign)
        print(
            indices.compactMap(\.type)
        )
    }

    func testCodeSignEntitlements() {
        guard let codeSign = machO.codeSign else {
            return
        }
        guard let entitlements = codeSign.embeddedEntitlements else {
            return
        }
        print(entitlements)
    }

    func testCodeSignCodeDirectories() {
        guard let codeSign = machO.codeSign else {
            return
        }
        let directories = codeSign.codeDirectories

        /* Identifier */
        let identifiers = directories
            .compactMap {
                $0.identifier(in: codeSign)
            }
        print(
            "identifier:",
            identifiers
        )

        /* CD Hash */
        let cdHashes = directories
            .compactMap {
                $0.hash(in: codeSign)
            }.map {
                $0.map { String(format: "%02x", $0) }.joined()
            }
        print(
            "CDHash:",
            cdHashes
        )

        /* Page Hashes*/
        //        let pageHashes = directories
        //            .map { directory in
        //                (-Int(directory.nSpecialSlots)..<Int(directory.nCodeSlots))
        //                    .map {
        //                        if let hash = directory.hash(forSlot: $0, in: codeSign) {
        //                            return "\($0) " + hash.map { String(format: "%02x", $0) }.joined()
        //                        } else {
        //                            return "\($0) unknown"
        //                        }
        //                    }
        //            }
        //        print(
        //            "PageHashes:",
        //            pageHashes
        //        )

        /* Team IDs */
        let teamIDs = directories
            .compactMap {
                $0.teamId(in: codeSign)
            }
        print(
            "TeamID:",
            teamIDs
        )

        /* Exec Segment */
        let execSeg = directories
            .compactMap {
                $0.executableSegment(in: codeSign)
            }
        print(
            "ExecSeg:",
            execSeg
        )

        /* Runtime */
        let runtime = directories
            .compactMap {
                $0.runtime(in: codeSign)
            }
        print(
            "Runtime:",
            runtime
        )
    }
}
