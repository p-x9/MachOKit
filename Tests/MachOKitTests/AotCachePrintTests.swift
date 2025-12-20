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

final class AotCachePrintTests: XCTestCase {
    private var cache: AotCache!
    private var x86DyldCache: FullDyldCache!

    override func setUp() {
        print("----------------------------------------------------")
        let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/aot_shared_cache.0"
        let url = URL(fileURLWithPath: path)

        self.cache = try! AotCache(url: url)

        let x86path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_x86_64"
        let x86Url = URL(fileURLWithPath: x86path)
        self.x86DyldCache = try! FullDyldCache(url: x86Url)
    }

    func testHeader() throws {
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
        let codeFragments = cache.codeFragments
        for fragment in codeFragments {
            print("----")

            let imagePath = fragment.imagePath(x86DyldCache: x86DyldCache)
            print(imagePath ?? "unknown")

            if let branchData = fragment.branchData(in: cache)  {
                let header = branchData.header
                print(header)

                if let entries = branchData.extendedEntries(in: cache) {
                    for branch in entries {
                        print(
                            String(branch.index, radix: 16),
                            String(branch._field2, radix: 16),
                            String(branch._field3, radix: 16),
                            String(branch._field4, radix: 16),
                            String(branch._field5, radix: 16),
                            String(branch._field6, radix: 16)
                        )
                    }
                }

                if let entries = branchData.entries(in: cache) {
                    for branch in entries {
                        print(
                            String(branch.index, radix: 16),
                            String(branch._field2, radix: 16),
                            String(branch._field3, radix: 16),
                            String(branch._field4, radix: 16)
                        )
                    }
                }

                if let entries = branchData.compactEntries(in: cache) {
                    for branch in entries {
                        print(
                            String(branch.index, radix: 16),
                            String(branch._field2, radix: 16),
                            String(branch._field3, radix: 16),
                            String(branch._field4, radix: 16)
                        )
                    }
                }
            }
        }
    }

    func testInstructionMap() {
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
