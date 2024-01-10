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
        guard let file = try? MachOKit.loadFromFile(url: url),
              case let .fat(fatFile) = file,
              let machOs = try? fatFile.machOFiles() else {
            XCTFail("Failed to load file")
            return
        }
        self.fat = fatFile
        self.machO = machOs[1]
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
        let symbols = Array(machO.symbols)
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
                        print("SymbolName:", symbols[symbolIndex].name)
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

    func testDependencies() throws {
        for dependency in machO.dependencies {
            print("----")
            print("Name:", dependency.name)
            print("CurrentVersion:", dependency.currentVersion)
            print("CompatibilityVersion:", dependency.compatibilityVersion)
            print("TimeStamp:", dependency.timestamp)
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
            if let description = symbol.nlist.symbolDescription {
                print("SymbolDescription:", description.bits)
                if let referenceFlag = description.referenceFlag {
                    print("ReferenceFlag:", referenceFlag)
                }
                let libraryOrdinal = Int(description.libraryOrdinal) - 1
                if libraryOrdinal == -1,
                   let info = Array(machO.loadCommands.infos(of: LoadCommand.idDylib)).first {
                    print("LibraryOrdinal:", info.dylib(in: machO).name)
                } else if machO.dependencies.indices.contains(libraryOrdinal) {
                    print("LibraryOrdinal:", machO.dependencies[libraryOrdinal].name)
                }
            }
        }
    }

    func testIndirectSymbols() throws {
        guard let _indirectSymbols = machO.indirectSymbols else { return }
        let symbols = Array(machO.symbols)
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
                    print(symbols[index].name)
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
        guard let exportTrieEntries = machO.exportTrieEntries else { return }
        for entry in exportTrieEntries {
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
                binding.library(in: machO)?.name ?? "unknown",
                binding.symbolName
            )
        }
    }

    func testExportedSymbols() throws {
        for symbol in machO.exportedSymbols {
            print("0x" + String(symbol.offset, radix: 16), symbol.name)
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
        let path = "/usr/local/bin/texindex" // has thread command
        let url = URL(fileURLWithPath: path)
        guard let machO = try? MachOFile(url: url) else { return }

        let commands = Array(machO.loadCommands.infos(of: LoadCommand.thread))
        + Array(machO.loadCommands.infos(of: LoadCommand.unixthread))

        for command in commands {
            print("Flavor:",
                  command.flavor(
                    in: machO,
                    cpuType: machO.header.cpuType!
                  )?.description ?? "unknown"
            )
            print("Count:", command.count(in: machO) ?? 0)
            if let state = command.state(in: machO) {
                print(
                    "State:",
                    state.withUnsafeBytes {
                        [UInt64]($0.bindMemory(to: UInt64.self))
                    }.map { "0x" + String($0, radix: 16) }
                        .joined(separator: ", ")
                )
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
        let name = "$s15GroupActivities0A16SessionMessengerC8MessagesV8IteratorV4nextx_AC14MessageContextVtSgyYaF"
        let demangledName = "GroupActivities.GroupSessionMessenger.Messages.Iterator.next() async -> Swift.Optional<(A, GroupActivities.GroupSessionMessenger.MessageContext)>"

        guard let symbol = machO.symbol(named: name) else {
            XCTFail("not found symbol named \"\(name)\"")
            return
        }
        print("found", symbol.name)
        XCTAssert(
            name == symbol.name ||
            "_" + name == symbol.name
        )

        guard let symbol2 = machO.symbol(named: demangledName, mangled: false) else {
            XCTFail("not found symbol named \"\(demangledName)\"")
            return
        }
        print("found", symbol2.name)
        XCTAssert(
            demangledName == stdlib_demangleName(symbol2.name)
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
