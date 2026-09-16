//
//  AotCachePrintTests+private.swift
//  MachOKit
//
//  Created by p-x9 on 2026/05/30
//  
//

import Foundation
import XCTest
@testable import MachOKit

extension AotCachePrintTests {
    enum DisassemblyArchitecture {
        case x86_64
        case arm64

        var target: String {
            switch self {
            case .x86_64: "x86_64-apple-macosx14.0"
            case .arm64: "arm64-apple-macosx14.0"
            }
        }

        var objdumpArguments: [String] {
            switch self {
            case .x86_64:
                [
                    "llvm-objdump",
                    "--macho",
                    "--disassemble",
                    "--no-leading-headers",
                    "--no-show-raw-insn",
                    "--x86-asm-syntax=intel"
                ]
            case .arm64:
                [
                    "llvm-objdump",
                    "--macho",
                    "--disassemble",
                    "--no-leading-headers",
                    "--no-show-raw-insn"
                ]
            }
        }
    }

    @discardableResult
    func printBranchEntries(
        fragment: AotCacheCodeFragment,
        fragmentIndex: Int,
        imagePath: String,
        branchData: AotBranchData,
        mapEntries: [AotInstructionMapIndexEntry],
        maxEntries: Int,
        maxRecords: Int
    ) -> Int {
        switch branchData.header.kind {
        case 1:
            guard let entries = branchData.compactEntries(in: cache) else { return 0 }
            return printBranchEntries(
                Array(entries),
                fragment: fragment,
                fragmentIndex: fragmentIndex,
                imagePath: imagePath,
                branchData: branchData,
                mapEntries: mapEntries,
                maxEntries: maxEntries,
                maxRecords: maxRecords
            )
        case 2:
            guard let entries = branchData.entries(in: cache) else { return 0 }
            return printBranchEntries(
                Array(entries),
                fragment: fragment,
                fragmentIndex: fragmentIndex,
                imagePath: imagePath,
                branchData: branchData,
                mapEntries: mapEntries,
                maxEntries: maxEntries,
                maxRecords: maxRecords
            )
        case 3:
            guard let entries = branchData.extendedEntries(in: cache) else { return 0 }
            return printBranchEntries(
                Array(entries),
                fragment: fragment,
                fragmentIndex: fragmentIndex,
                imagePath: imagePath,
                branchData: branchData,
                mapEntries: mapEntries,
                maxEntries: maxEntries,
                maxRecords: maxRecords
            )
        default:
            print(
                "branch_data/payload_samples unsupported_kind",
                "kind:", branchData.header.kind,
                "fragmentIndex:", fragmentIndex,
                "image:", imagePath
            )
            return 0
        }
    }

    @discardableResult
    func printBranchEntries<Entry: AotBranchDataPayloadEntry>(
        _ entries: [Entry],
        fragment: AotCacheCodeFragment,
        fragmentIndex: Int,
        imagePath: String,
        branchData: AotBranchData,
        mapEntries: [AotInstructionMapIndexEntry],
        maxEntries: Int,
        maxRecords: Int
    ) -> Int {
        var printedEntries = 0

        for (entryIndex, entry) in entries.enumerated() where entry.payloadRecordCount > 0 {
            guard let locations = payloadLocations(for: entry, branchData: branchData) else {
                continue
            }

            for (recordIndex, record) in locations.prefix(maxRecords).enumerated() {
                let nearestMap = nearestInstructionMapEntry(
                    to: record,
                    entries: mapEntries
                )
                let x86Delta = nearestMap.map {
                    record.x86CodeOffset - $0.x86CodeOffset
                }
                let armDelta = nearestMap.map {
                    record.armCodeOffset - $0.armCodeOffset
                }

                let nearestMapText = nearestMap.map {
                    "\(hex($0.x86CodeOffset))/\(hex($0.armCodeOffset))"
                } ?? "-"
                let row: [String] = [
                    String(fragmentIndex),
                    String(imagePath.split(separator: "/").last ?? ""),
                    String(branchData.header.kind),
                    hex(numericCast(fragment.layout.x86_code_offset)),
                    hex(numericCast(fragment.layout.arm_code_offset)),
                    String(entryIndex),
                    String(recordIndex),
                    hex(record.x86CodeOffset),
                    hex(record.armCodeOffset),
                    String(record.x86CodeOffset < numericCast(fragment.layout.x86_code_size)),
                    String(record.armCodeOffset < numericCast(fragment.layout.arm_code_size)),
                    nearestMapText,
                    x86Delta.map(String.init) ?? "-",
                    armDelta.map(String.init) ?? "-"
                ]
                print(row.joined(separator: "\t"))
            }

            printedEntries += 1
            if printedEntries >= maxEntries {
                break
            }
        }

        return printedEntries
    }

    func payloadLocations<Entry: AotBranchDataPayloadEntry>(
        for entry: Entry,
        branchData: AotBranchData
    ) -> [AotBranchDataPayloadLocation]? {
        if let entry = entry as? AotBranchDataIndexEntryCompact {
            return branchData.payloadLocations(for: entry, in: cache)
        } else if let entry = entry as? AotBranchDataIndexEntry {
            return branchData.payloadLocations(for: entry, in: cache)
        } else if let entry = entry as? AotBranchDataIndexEntryExtended {
            return branchData.payloadLocations(for: entry, in: cache)
        } else {
            return nil
        }
    }

    func nearestInstructionMapEntry(
        to record: AotBranchDataPayloadLocation,
        entries: [AotInstructionMapIndexEntry]
    ) -> AotInstructionMapIndexEntry? {
        entries.min {
            distance(from: record, to: $0) < distance(from: record, to: $1)
        }
    }

    func distance(
        from record: AotBranchDataPayloadLocation,
        to entry: AotInstructionMapIndexEntry
    ) -> Int {
        abs(record.x86CodeOffset - entry.x86CodeOffset)
        + abs(record.armCodeOffset - entry.armCodeOffset)
    }

    func x86Bytes(
        fragment: AotCacheCodeFragment,
        record: AotBranchDataPayloadLocation,
        count: Int
    ) -> Data? {
        x86Bytes(
            fragment: fragment,
            x86CodeOffset: record.x86CodeOffset,
            count: count
        )
    }

    func x86FileOffsetBytes(
        fragment: AotCacheCodeFragment,
        record: AotBranchDataPayloadLocation,
        count: Int
    ) -> Data? {
        guard let x86DyldCache else { return nil }

        return try? x86DyldCache.fileHandle.readData(
            offset: numericCast(fragment.layout.x86_code_offset) + record.x86CodeOffset,
            length: count
        )
    }

    func x86Bytes(
        fragment: AotCacheCodeFragment,
        x86CodeOffset: Int,
        count: Int
    ) -> Data? {
        guard let x86DyldCache,
              let fileOffset = x86FileOffset(
                  fragment: fragment,
                  x86CodeOffset: x86CodeOffset
              ) else {
            return nil
        }

        return try? x86DyldCache.fileHandle.readData(
            offset: fileOffset,
            length: count
        )
    }

    func x86FileOffset(
        fragment: AotCacheCodeFragment,
        x86CodeOffset: Int
    ) -> Int? {
        guard let x86DyldCache else { return nil }

        let x86Offset = UInt64(fragment.layout.x86_code_offset) + UInt64(x86CodeOffset)
        let address = x86DyldCache.mainCacheHeader.sharedRegionStart + x86Offset
        guard let fileOffset = x86DyldCache.fileOffset(of: address) else {
            return nil
        }
        return numericCast(fileOffset)
    }

    func armBytes(
        fragment: AotCacheCodeFragment,
        record: AotBranchDataPayloadLocation,
        count: Int
    ) -> Data? {
        armBytes(
            fragment: fragment,
            armCodeOffset: record.armCodeOffset,
            count: count
        )
    }

    func armBytes(
        fragment: AotCacheCodeFragment,
        armCodeOffset: Int,
        count: Int
    ) -> Data? {
        let mappings = Array(cache.mappingInfos)
        guard mappings.count > 2 else { return nil }
        let executableMapping = mappings[2]
        return try? cache.fileHandle.readData(
            offset: numericCast(executableMapping.fileOffset)
            + numericCast(fragment.layout.arm_code_offset)
            + armCodeOffset,
            length: count
        )
    }

    func printInstructionMapSubmapSample(
        title: String,
        fragmentIndex: Int,
        submapIndex: Int,
        instructionMap: AotInstructionMap
    ) {
        guard let submap = instructionMap.submap(
            at: submapIndex,
            in: cache
        ) else {
            print(
                "instruction_map/submap_sample unavailable:",
                title,
                "fragmentIndex:", fragmentIndex,
                "submapIndex:", submapIndex
            )
            return
        }

        do {
            guard let indexEntry = try submap.indexEntry(
                for: instructionMap,
                in: cache
            ) else {
                print(
                    "instruction_map/submap_sample index_entry_unavailable:",
                    title,
                    "fragmentIndex:", fragmentIndex,
                    "submapIndex:", submapIndex
                )
                return
            }
            guard let entries = try submap.entries(
                for: instructionMap,
                in: cache
            ) else {
                print(
                    "instruction_map/submap_sample entries_unavailable:",
                    title,
                    "fragmentIndex:", fragmentIndex,
                    "submapIndex:", submapIndex
                )
                return
            }

            let decodedLocations = decodedLocations(
                entries: entries,
                indexEntry: indexEntry,
                header: instructionMap.header
            )
            let firstEntries = decodedLocations.prefix(8)
            let lastEntries = decodedLocations.suffix(8)
            let rawDeltaCount = entries.filter {
                $0.usesRawDelta
            }.count
            let metadataCount = entries.filter {
                $0.metadata != 0
            }.count
            let submapSize = instructionMap.submapSize(
                at: submapIndex,
                in: cache
            ) ?? 0
            let prefixData = (try? cache.fileHandle.readData(
                offset: submap.offset,
                length: min(submapSize, 32)
            )) ?? Data()

            print("")
            print("instruction_map/submap_sample:", title)
            print(
                " fragmentIndex:", fragmentIndex,
                " submapIndex:", submapIndex,
                " mapOffset:", hex(instructionMap.offset),
                " mapSize:", instructionMap.header.mapSize
            )
            print(
                " entry:",
                "x86:", hex(indexEntry.x86CodeOffset),
                "arm:", hex(indexEntry.armCodeOffset),
                "submapOffset:", hex(indexEntry.submapOffset),
                "deltaCount:", indexEntry.submapDeltaCount
            )
            print(
                " payload:",
                "fileOffset:", hex(submap.offset),
                "size:", submapSize,
                "prefix:", prefixData.prefixHexString(count: 32)
            )
            print(
                " decoded:",
                "entries:", entries.count,
                "rawDeltaCount:", rawDeltaCount,
                "metadataCount:", metadataCount
            )
            print(" first entries:")
            for location in firstEntries {
                printDecodedEntry(location)
            }
            if decodedLocations.count > firstEntries.count {
                print(" last entries:")
                for location in lastEntries {
                    printDecodedEntry(location)
                }
            }
        } catch {
            print(
                "instruction_map/submap_sample decode_error:",
                title,
                "fragmentIndex:", fragmentIndex,
                "submapIndex:", submapIndex,
                "error:", error
            )
        }
    }

    func decodedLocations(
        entries: [AotInstructionMapSubmapEntry],
        indexEntry: AotInstructionMapIndexEntry,
        header: AotInstructionMapHeader
    ) -> [(index: Int, x86CodeOffset: Int, armCodeOffset: Int, entry: AotInstructionMapSubmapEntry)] {
        var x86CodeOffset = indexEntry.x86CodeOffset
        var armCodeOffset = indexEntry.armCodeOffset
        var locations: [(index: Int, x86CodeOffset: Int, armCodeOffset: Int, entry: AotInstructionMapSubmapEntry)] = []
        locations.reserveCapacity(entries.count)

        for (index, entry) in entries.enumerated() {
            x86CodeOffset = wrappingAdd32(
                x86CodeOffset,
                entry.x86CodeDelta
            )
            armCodeOffset = wrappingAdd32(
                armCodeOffset,
                entry.armInstructionDelta * header.armInstructionByteSize
            )
            locations.append((
                index: index,
                x86CodeOffset: x86CodeOffset,
                armCodeOffset: armCodeOffset,
                entry: entry
            ))
        }

        return locations
    }

    func printDecodedEntry(
        _ location: (
            index: Int,
            x86CodeOffset: Int,
            armCodeOffset: Int,
            entry: AotInstructionMapSubmapEntry
        )
    ) {
        let entry = location.entry
        print(
            "  [\(location.index)]",
            "x86:", hex(location.x86CodeOffset),
            "arm:", hex(location.armCodeOffset),
            "dx:", signed32Description(entry.x86CodeDelta),
            "dARMInst:", signed32Description(entry.armInstructionDelta),
            "metadata:", entry.metadata,
            "kind:", entry.kind.map(String.init) ?? "nil",
            "raw:", entry.usesRawDelta
        )
    }

    func wrappingAdd32(_ lhs: Int, _ rhs: Int) -> Int {
        let value = UInt32(truncatingIfNeeded: lhs)
        &+ UInt32(truncatingIfNeeded: rhs)
        return numericCast(value)
    }

    func hex(_ value: Int) -> String {
        "0x" + String(UInt64(UInt32(truncatingIfNeeded: value)), radix: 16)
    }

    func signed32Description(_ value: Int) -> String {
        let rawValue = UInt32(truncatingIfNeeded: value)
        let signedValue = Int32(bitPattern: rawValue)
        return signedValue.description
    }

    func hexBytes(_ data: Data?) -> String {
        guard let data else { return "-" }
        return data.map { String(format: "%02x", $0) }.joined(separator: " ")
    }

    func disassemble(
        bytes: Data,
        architecture: DisassemblyArchitecture,
        name: String
    ) -> String {
        guard !bytes.isEmpty else { return "  <empty>" }

        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(
                "machokit-aot-disasm-\(UUID().uuidString)",
                isDirectory: true
            )
        let assemblyURL = temporaryDirectory.appendingPathComponent("\(name).s")
        let objectURL = temporaryDirectory.appendingPathComponent("\(name).o")

        do {
            try FileManager.default.createDirectory(
                at: temporaryDirectory,
                withIntermediateDirectories: true
            )
            defer {
                try? FileManager.default.removeItem(at: temporaryDirectory)
            }

            let byteList = bytes
                .map { String(format: "0x%02x", $0) }
                .joined(separator: ", ")
            let assembly = """
            .text
            .globl _sample
            _sample:
            .byte \(byteList)
            """
            try assembly.write(to: assemblyURL, atomically: true, encoding: .utf8)

            let clangResult = try runProcess(
                arguments: [
                    "clang",
                    "-target",
                    architecture.target,
                    "-c",
                    assemblyURL.path,
                    "-o",
                    objectURL.path
                ]
            )
            guard clangResult.status == 0 else {
                return "  clang failed:\n\(indent(clangResult.output))"
            }

            let objdumpResult = try runProcess(
                arguments: architecture.objdumpArguments + [objectURL.path]
            )
            guard objdumpResult.status == 0 else {
                return "  llvm-objdump failed:\n\(indent(objdumpResult.output))"
            }

            return indent(objdumpResult.output)
        } catch {
            return "  disassembly failed: \(error)"
        }
    }

    func runProcess(arguments: [String]) throws -> (status: Int32, output: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""
        return (
            process.terminationStatus,
            [output, error]
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        )
    }

    func indent(_ string: String) -> String {
        string
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "  \($0)" }
            .joined(separator: "\n")
    }
}

private extension Data {
    func prefixHexString(count: Int) -> String {
        prefix(count)
            .map { String(format: "%02x", $0) }
            .joined(separator: " ")
    }
}
