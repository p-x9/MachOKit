//
//  AotCachePrintTests.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/20
//  
//

import XCTest
@testable import MachOKit
import FileIO
import FileIOBinary

final class AotCachePrintTests: XCTestCase {
    var cache: AotCache!
    var x86DyldCache: FullDyldCache!

    override func setUp() {
        print("----------------------------------------------------")
        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/aot_shared_cache.0"
        let url = URL(fileURLWithPath: path)

        self.cache = try? AotCache(url: url)

        let x86path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_x86_64"
        let x86Url = URL(fileURLWithPath: x86path)
        self.x86DyldCache = try? FullDyldCache(url: x86Url)
    }

    func testHeader() throws {
        guard let cache else {
            print("aot_cache/header skipped: AOT cache is not available")
            return
        }

        let header = cache.header
        print("Magic:", header.magic)
        print("UUID:", header.uuid)
        print("X86 UUID:", header.x86UUID)
        print(
            "Version",
            withUnsafePointer(to: header.layout.cambria_version) {
                let size = CAMBRIA_VERSION_INFO_SIZE
                let data = Data(bytes: $0, count: Int(size))
                return data.map { String(format: "%02x", $0) }.joined()
            }
        )
        print("CodeFragments", header.num_code_fragments)
        // dump(header.layout)
    }

    func testMappingInfos() throws {
        guard let cache else {
            print("aot_cache/mapping_infos skipped: AOT cache is not available")
            return
        }

        let infos = cache.mappingInfos
        for info in infos {
            print("----")
            print("Address:", String(info.address, radix: 16))
            print("File Offset::", String(info.fileOffset, radix: 16))
            print("Size:", String(info.size, radix: 16))
            print("MaxProtection:", info.maxProtection.bits)
            print("InitProtection:", info.initialProtection.bits)
        }
    }
}

extension AotCachePrintTests {
    func testCodeFragments() {
        guard let cache else {
            print("aot_cache/code_fragments skipped: AOT cache is not available")
            return
        }

        let codeFragments = cache.codeFragments
        for fragment in codeFragments {
            print("----")
            let imagePath = fragment.imagePath(x86DyldCache: x86DyldCache)
            print(imagePath ?? "unknown")
            print("", "type:", fragment.type)
            print(
                "", "x86_code_offset:",
                "0x" + String(fragment.x86_code_offset, radix: 16)
            )
            print(
                "", "x86_code_size:",
                "0x" + String(fragment.x86_code_size, radix: 16)
            )
            print(
                "", "arm_code_offset:",
                "0x" + String(fragment.arm_code_offset, radix: 16)
            )
            print(
                "", "arm_code_size:",
                "0x" + String(fragment.arm_code_size, radix: 16)
            )
        }
    }

    func testBranchData() {
        guard let cache else {
            print("aot_cache/branch_data skipped: AOT cache is not available")
            return
        }

        let codeFragments = cache.codeFragments
        for fragment in codeFragments {
            print("----")

            let imagePath = fragment.imagePath(x86DyldCache: x86DyldCache)
            print(imagePath ?? "unknown")

            if let branchData = fragment.branchData(in: cache) {
                let header = branchData.header
                print(header)

                if let entries = branchData.extendedEntries(in: cache) {
                    for branch in entries {
                        print(
                            String(branch.x86CodeBucket, radix: 16),
                            String(branch.armCodeBucket, radix: 16),
                            String(branch.payloadRecordCount, radix: 16),
                            String(branch.payloadRecordOffset, radix: 16)
                        )
                    }
                }

                if let entries = branchData.entries(in: cache) {
                    for branch in entries {
                        print(
                            String(branch.x86CodeBucket, radix: 16),
                            String(branch.armCodeBucket, radix: 16),
                            String(branch.payloadRecordCount, radix: 16),
                            String(branch.payloadRecordOffset, radix: 16)
                        )
                    }
                }

                if let entries = branchData.compactEntries(in: cache) {
                    for branch in entries {
                        print(
                            String(branch.x86CodeBucket, radix: 16),
                            String(branch.armCodeBucket, radix: 16),
                            String(branch.payloadRecordCount, radix: 16),
                            String(branch.payloadRecordOffset, radix: 16)
                        )
                    }
                }
            }
        }
    }

    func testInstructionMap() {
        guard let cache else {
            print("aot_cache/instruction_map skipped: AOT cache is not available")
            return
        }

        let codeFragments = cache.codeFragments
        for fragment in codeFragments {
            print("----")

            let imagePath = fragment.imagePath(x86DyldCache: x86DyldCache)
            print(imagePath ?? "unknown")

            if let map = fragment.instructionMap(in: cache) {
                print("", map.header)
                for inst in map.entries(in: cache) {
                    print(inst)
                }
            }
        }
    }
}

extension AotCachePrintTests {
    func testPrintBranchDataPayloadSamples() {
        guard let cache else {
            print("branch_data/payload_samples skipped: AOT cache is not available")
            return
        }
        guard let x86DyldCache else {
            print("branch_data/payload_samples skipped: x86 dyld cache is not available")
            return
        }

        let maxFragments = 3
        let maxEntriesPerFragment = 3
        let maxRecordsPerEntry = 8
        var printedFragments = 0

        print([
            "fragment",
            "image",
            "kind",
            "x86Base",
            "armBase",
            "entry",
            "record",
            "x86Off",
            "armOff",
            "inX86",
            "inARM",
            "nearestMap",
            "dx86",
            "darm"
        ].joined(separator: "\t"))

        for (fragmentIndex, fragment) in cache.codeFragments.enumerated() {
            guard fragment.type != .runtime,
                  let branchData = fragment.branchData(in: cache),
                  let instructionMap = fragment.instructionMap(in: cache) else {
                continue
            }

            let imagePath = fragment.imagePath(x86DyldCache: x86DyldCache) ?? "unknown"
            let mapEntries = Array(instructionMap.entries(in: cache))
            let printedEntries = printBranchEntries(
                fragment: fragment,
                fragmentIndex: fragmentIndex,
                imagePath: imagePath,
                branchData: branchData,
                mapEntries: mapEntries,
                maxEntries: maxEntriesPerFragment,
                maxRecords: maxRecordsPerEntry
            )

            if printedEntries > 0 {
                printedFragments += 1
                if printedFragments >= maxFragments {
                    break
                }
            }
        }

        print(
            "branch_data/payload_samples",
            "printedFragments:", printedFragments,
            "maxFragments:", maxFragments
        )
    }

    func testPrintInstructionMapSubmapSamples() {
        guard let cache else {
            print("instruction_map/submap_samples skipped: AOT cache is not available")
            return
        }

        var printedSamples = 0
        var printedMiddleNonStandardCount = false
        var printedTerminal = false

        for (fragmentIndex, fragment) in cache.codeFragments.enumerated() {
            guard let instructionMap = fragment.instructionMap(in: cache) else {
                continue
            }

            let entries = Array(instructionMap.entries(in: cache))
            guard !entries.isEmpty else { continue }

            if printedSamples == 0 {
                printInstructionMapSubmapSample(
                    title: "first submap",
                    fragmentIndex: fragmentIndex,
                    submapIndex: 0,
                    instructionMap: instructionMap
                )
                printedSamples += 1
            }

            if entries.count > 1, printedSamples == 1 {
                printInstructionMapSubmapSample(
                    title: "second submap",
                    fragmentIndex: fragmentIndex,
                    submapIndex: 1,
                    instructionMap: instructionMap
                )
                printedSamples += 1
            }

            if !printedMiddleNonStandardCount,
               let index = entries.dropLast().firstIndex(where: {
                   $0.submapDeltaCount != 0x101
               }) {
                printInstructionMapSubmapSample(
                    title: "middle non-0x101 count",
                    fragmentIndex: fragmentIndex,
                    submapIndex: index,
                    instructionMap: instructionMap
                )
                printedMiddleNonStandardCount = true
            }

            if !printedTerminal {
                let lastIndex = entries.index(before: entries.endIndex)
                printInstructionMapSubmapSample(
                    title: "terminal submap",
                    fragmentIndex: fragmentIndex,
                    submapIndex: lastIndex,
                    instructionMap: instructionMap
                )
                printedTerminal = true
            }

            if printedSamples >= 2,
               printedMiddleNonStandardCount,
               printedTerminal {
                break
            }
        }

        print(
            "instruction_map/submap_samples",
            "printedSamples:", printedSamples,
            "printedMiddleNonStandardCount:", printedMiddleNonStandardCount,
            "printedTerminal:", printedTerminal
        )
    }
}

extension AotCachePrintTests {
    func testPrintInstructionMapDisassemblySamples() {
        guard let cache else {
            print("instruction_map/disassembly_samples skipped: AOT cache is not available")
            return
        }
        guard x86DyldCache != nil else {
            print("instruction_map/disassembly_samples skipped: x86 dyld cache is not available")
            return
        }

        let maxSamples = 4
        var printedSamples = 0

        for (fragmentIndex, fragment) in cache.codeFragments.enumerated() {
            guard fragment.type != .runtime,
                  let instructionMap = fragment.instructionMap(in: cache),
                  let submap = instructionMap.submap(at: 0, in: cache) else {
                continue
            }

            let imagePath = fragment.imagePath(x86DyldCache: x86DyldCache) ?? "unknown"

            do {
                guard let indexEntry = try submap.indexEntry(
                    for: instructionMap,
                    in: cache
                ),
                      let entries = try submap.entries(
                          for: instructionMap,
                          in: cache
                      ) else {
                    continue
                }

                let locations = decodedLocations(
                    entries: entries,
                    indexEntry: indexEntry,
                    header: instructionMap.header
                )

                for location in locations {
                    guard let x86Code = x86Bytes(
                        fragment: fragment,
                        x86CodeOffset: location.x86CodeOffset,
                        count: 24
                    ),
                          let armCode = armBytes(
                              fragment: fragment,
                              armCodeOffset: location.armCodeOffset,
                              count: 24
                          ),
                          x86Code.first != 0,
                          armCode.first != 0,
                          !x86Code.allSatisfy({ $0 == 0 }),
                          !armCode.allSatisfy({ $0 == 0 }) else {
                        continue
                    }

                    print("")
                    print(
                        "instruction_map/disassembly_sample",
                        "fragmentIndex:", fragmentIndex,
                        "image:", imagePath,
                        "entryIndex:", location.index,
                        "x86:", hex(location.x86CodeOffset),
                        "arm:", hex(location.armCodeOffset),
                        "dx:", signed32Description(location.entry.x86CodeDelta),
                        "dARMInst:", signed32Description(location.entry.armInstructionDelta),
                        "metadata:", location.entry.metadata,
                        "raw:", location.entry.usesRawDelta
                    )
                    print(" x86 bytes:", hexBytes(x86Code))
                    print(" x86 disassembly:")
                    print(disassemble(
                        bytes: x86Code,
                        architecture: .x86_64,
                        name: "x86_\(fragmentIndex)_\(location.index)"
                    ))
                    print(" arm64 bytes:", hexBytes(armCode))
                    print(" arm64 disassembly:")
                    print(disassemble(
                        bytes: armCode,
                        architecture: .arm64,
                        name: "arm64_\(fragmentIndex)_\(location.index)"
                    ))

                    printedSamples += 1
                    if printedSamples >= maxSamples {
                        print(
                            "instruction_map/disassembly_samples",
                            "printedSamples:", printedSamples,
                            "maxSamples:", maxSamples
                        )
                        return
                    }
                }
            } catch {
                print(
                    "instruction_map/disassembly_samples decode_error",
                    "fragmentIndex:", fragmentIndex,
                    "image:", imagePath,
                    "error:", error
                )
            }
        }

        print(
            "instruction_map/disassembly_samples",
            "printedSamples:", printedSamples,
            "maxSamples:", maxSamples
        )
    }
}
