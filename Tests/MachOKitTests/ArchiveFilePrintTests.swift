//
//  ArchiveFilePrintTests.swift
//  MachOKit
//
//  Created by p-x9 on 2026/03/16
//
//

import Foundation
import XCTest
@testable import MachOKit
import ObjectArchiveKit
import MachOArchiveKit

final class ArchiveFileTests: XCTestCase {
    var fat: FatFile!
    var archive: ArchiveFile!

    override func setUp() async throws {
        let developerDirectoryURL = try developerDirectoryURL()
        let url = developerDirectoryURL
            .appendingPathComponent("Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/17/lib/darwin/libclang_rt.osx.a")
        let file = try MachOKit.loadFromFile(url: url)
        switch file {
        case let .fat(fat):
            self.fat = fat
            let archives = try fat.archiveFiles()
            self.archive = archives[0]
        case .machO:
            XCTFail("Expected archive or fat archive file")
            return
        }
    }

    func testDumpFileStructure() throws {
        func dump(_ machO: MachOFile, level: Int) {
            let path = machO.imagePath
            let name = path.split(separator: "/").last ?? ""
            print(String(repeating: " ", count: level) + name)
        }

        func dump(_ fat: FatFile, level: Int) {
            print(String(repeating: " ", count: level) + "Fat", fat.url.lastPathComponent)
            do {
                let machOs = try fat.machOFiles()
                for machO in machOs {
                    dump(machO, level: level + 1)
                }
            } catch {}
            do {
                let archives = try fat.archiveFiles()
                let archs = fat.arches
                for (archive, arch) in zip(archives, archs) {
                    dump(archive, level: level + 1, cpu: arch.cpu)
                }
            } catch {}
        }

        func dump(_ archive: ArchiveFile, level: Int, cpu: CPU) {
            print(String(repeating: " ", count: level) + "Archive", cpu)
            do {
                let machOs = try archive.machOFiles()
                for machO in machOs.prefix(5) {
                    dump(machO, level: level + 1)
                }
                print(String(repeating: " ", count: level + 1) + "...")
            } catch {}
        }

        dump(fat, level: 0)
    }
}

extension ArchiveFileTests {
    func testBSDSymbols() throws {
        guard let symbolTable = archive.bsdSymbolTable else {
            return
        }
        print("count: \(symbolTable.count)")
        print("isSorted: \(symbolTable.isSorted(in: archive))")
        for symbol in try symbolTable.entries(in: archive) {
            let name = try symbolTable.name(for: symbol, in: archive)
            print(name ?? "unknown", symbol.stringOffset, symbol.headerOffset)
        }
    }

    func testDarwin64Symbols() throws {
        guard let symbolTable = archive.darwin64SymbolTable else {
            return
        }
        print("count: \(symbolTable.count)")
        print("isSorted: \(symbolTable.isSorted(in: archive))")
        for symbol in try symbolTable.entries(in: archive) {
            let name = try symbolTable.name(for: symbol, in: archive)
            print(name ?? "unknown", symbol.stringOffset, symbol.headerOffset)
        }
    }
}

extension ArchiveFileTests {
    private func developerDirectoryURL() throws -> URL {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
        process.arguments = ["-p"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if var path = String(data: data, encoding: .utf8) {
            path.removeLast()
            return URL(fileURLWithPath: path)
        }
        fatalError("Failed to read Xcode install path")
    }
}
