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

    var fat: FatFile!
    var machO: MachOFile!

    override func setUp() {
        print("----------------------------------------------------")
        let path = "/System/Applications/Calculator.app/Contents/MacOS/Calculator"
//        let path = "/System/Applications/Calculator.app/Contents/PlugIns/BasicAndSci.calcview/Contents/MacOS/BasicAndSci"
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

    func testSymbolStrings() throws {
        guard let cstrings = machO.symbolStrings else { return }
        for (i, cstring) in cstrings.enumerated() {
            let offset = Int(machO.loadCommands.symtab!.stroff) + cstring.offset
            print(i, "0x" + String(offset, radix: 16), cstring.string)
        }
    }

    func testCStrings() throws {
        guard let cstrings = machO.cStrings else { return }
        let section = machO.loadCommands.text64!.sections(in: machO).filter {
            $0.sectionName == "__cstring"
        }.first!
        for (i, cstring) in cstrings.enumerated() {
            let offset = Int(section.offset) + cstring.offset
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
}
