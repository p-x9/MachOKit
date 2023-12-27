//
//  MachOPrintTests.swift
//  
//
//  Created by p-x9 on 2023/12/19.
//  
//

import XCTest
@testable import MachOKit

final class MachOPrintTests: XCTestCase {
    private var machO: MachOImage!

    override func setUp() {
        machO = MachOImage(name: "MachOKitTests")
    }

    func testHeader() throws {
        let header = machO.header
        print("----")
        print("Magic:", header.magic!)
        print("CPU:", header.cpu)
        print("FileType:", header.fileType?.description ?? "unknown")
        print("Flags:", header.flags.bits.map(\.description).joined(separator: ", "))
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
                    print("LibraryOrdinal:", info.dylib(cmdsStart: machO.cmdsStartPtr).name)
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
            let ptr = cstrings.basePointer.advanced(by: cstring.offset)
            print(i, "0x" + String(Int(bitPattern: ptr), radix: 16), cstring.string)
        }
    }

    func testCStrings() throws {
        guard let cstrings = machO.cStrings else { return }
        for (i, cstring) in cstrings.enumerated() {
            let ptr = cstrings.basePointer.advanced(by: cstring.offset)
            print(i, "0x" + String(Int(bitPattern: ptr), radix: 16), cstring.string)
        }
    }

    func testAllCStrings() throws {
        for (i, cstring) in machO.allCStrings.enumerated() {
            print(i, cstring)
        }
    }
}

extension MachOPrintTests {
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

extension MachOPrintTests {
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

extension MachOPrintTests {
    func testLoadDylinkerCommand() {
        for info in machO.loadCommands.infos(of: LoadCommand.loadDylinker) {
            print(info.name(cmdsStart: machO.cmdsStartPtr))
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
            let tools = info.tools(cmdsStart: machO.cmdsStartPtr)
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
                print($0.count, $0.options(cmdsStart: machO.cmdsStartPtr))
            }
    }

    func testThreadCommand() {
        let commands = Array(machO.loadCommands.infos(of: LoadCommand.thread))
        + Array(machO.loadCommands.infos(of: LoadCommand.unixthread))

        for command in commands {
            print("Flavor:",
                  command.flavor(
                    cmdsStart: machO.cmdsStartPtr,
                    cpuType: machO.header.cpuType!
                  )?.description ?? "unknown"
            )
            print("Count:", command.count(cmdsStart: machO.cmdsStartPtr) ?? 0)
            if let state = command.state(cmdsStart: machO.cmdsStartPtr) {
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
