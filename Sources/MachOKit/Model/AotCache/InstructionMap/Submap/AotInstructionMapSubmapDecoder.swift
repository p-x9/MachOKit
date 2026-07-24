//
//  AotInstructionMapSubmapDecoder.swift
//  MachOKit
//
//  Created by p-x9 on 2026/05/26
//  
//

enum AotInstructionMapSubmapDecoder {
    static func decode(
        submap: AotInstructionMapSubmap,
        header: AotInstructionMapHeader,
        entry: AotInstructionMapIndexEntry,
        fileHandle: AotCache.File
    ) throws -> [AotInstructionMapSubmapEntry] {
        var reader = BitReader(
            offset: submap.offset,
            fileHandle: fileHandle
        )
        var entries: [AotInstructionMapSubmapEntry] = []
        entries.reserveCapacity(entry.submapDeltaCount)

        for _ in 0..<entry.submapDeltaCount {
            entries.append(
                try reader.readEntry(
                    x86CodeDeltaRiceWidth: header.x86CodeDeltaRiceWidth,
                    armInstructionDeltaRiceWidth: header.armInstructionDeltaRiceWidth
                )
            )
        }

        return entries
    }
}

private extension AotInstructionMapSubmapDecoder {
    struct BitReader {
        var byteOffset: Int
        var bitOffset = 0
        var byte: UInt8 = 0
        var hasByte = false
        let fileHandle: AotCache.File

        init(
            offset: Int,
            fileHandle: AotCache.File
        ) {
            self.byteOffset = offset
            self.fileHandle = fileHandle
        }

        mutating func readEntry(
            x86CodeDeltaRiceWidth: Int,
            armInstructionDeltaRiceWidth: Int
        ) throws -> AotInstructionMapSubmapEntry {
            let armInstructionDelta = try readRiceEncodedInteger(
                width: armInstructionDeltaRiceWidth
            )
            if armInstructionDelta > 0 {
                return .init(
                    x86CodeDelta: try readRiceEncodedInteger(
                        width: x86CodeDeltaRiceWidth
                    ),
                    armInstructionDelta: armInstructionDelta,
                    metadata: 0,
                    kind: nil,
                    usesRawDelta: false
                )
            }

            let kind = try readRiceEncodedInteger(
                width: armInstructionDeltaRiceWidth
            )
            switch kind {
            case 0:
                let armInstructionDelta = try readRaw32()
                let x86CodeDelta = try readRaw32()
                return .init(
                    x86CodeDelta: x86CodeDelta,
                    armInstructionDelta: armInstructionDelta,
                    metadata: 0,
                    kind: kind,
                    usesRawDelta: true
                )
            case 1:
                return try readSpecialDelta(
                    metadata: 1,
                    kind: kind,
                    x86CodeDeltaRiceWidth: x86CodeDeltaRiceWidth,
                    armInstructionDeltaRiceWidth: armInstructionDeltaRiceWidth
                )
            case 2:
                let metadata = 1 | (try readRiceEncodedInteger(
                    width: armInstructionDeltaRiceWidth
                ) << 8)
                return try readSpecialDelta(
                    metadata: metadata,
                    kind: kind,
                    x86CodeDeltaRiceWidth: x86CodeDeltaRiceWidth,
                    armInstructionDeltaRiceWidth: armInstructionDeltaRiceWidth
                )
            case 3:
                return try readSpecialDelta(
                    metadata: 2,
                    kind: kind,
                    x86CodeDeltaRiceWidth: x86CodeDeltaRiceWidth,
                    armInstructionDeltaRiceWidth: armInstructionDeltaRiceWidth
                )
            case 4:
                return try readSpecialDelta(
                    metadata: 3,
                    kind: kind,
                    x86CodeDeltaRiceWidth: x86CodeDeltaRiceWidth,
                    armInstructionDeltaRiceWidth: armInstructionDeltaRiceWidth
                )
            default:
                return try readSpecialDelta(
                    metadata: 0,
                    kind: kind,
                    x86CodeDeltaRiceWidth: x86CodeDeltaRiceWidth,
                    armInstructionDeltaRiceWidth: armInstructionDeltaRiceWidth
                )
            }
        }

        mutating func readSpecialDelta(
            metadata: Int,
            kind: Int,
            x86CodeDeltaRiceWidth: Int,
            armInstructionDeltaRiceWidth: Int
        ) throws -> AotInstructionMapSubmapEntry {
            var armInstructionDelta = try readRiceEncodedInteger(
                width: armInstructionDeltaRiceWidth
            )
            let x86CodeDelta: Int
            let usesRawDelta: Bool

            if armInstructionDelta > 0 {
                x86CodeDelta = try readRiceEncodedInteger(
                    width: x86CodeDeltaRiceWidth
                )
                usesRawDelta = false
            } else {
                armInstructionDelta = try readRaw32()
                x86CodeDelta = try readRaw32()
                usesRawDelta = true
            }

            return .init(
                x86CodeDelta: x86CodeDelta,
                armInstructionDelta: armInstructionDelta,
                metadata: metadata,
                kind: kind,
                usesRawDelta: usesRawDelta
            )
        }

        mutating func readRiceEncodedInteger(width: Int) throws -> Int {
            var quotient = 0
            while try readBit() {
                quotient += 1
            }

            var remainder = 0
            for index in 0..<width {
                if try readBit() {
                    remainder |= 1 << index
                }
            }

            return (quotient << width) | remainder
        }

        mutating func readRaw32() throws -> Int {
            var value = 0
            for index in 0..<32 {
                if try readBit() {
                    value |= 1 << index
                }
            }
            return value
        }

        mutating func readBit() throws -> Bool {
            if !hasByte {
                byte = try fileHandle.read(offset: byteOffset)
                hasByte = true
            }

            let bit = (byte >> UInt8(bitOffset)) & 1
            bitOffset += 1
            if bitOffset == 8 {
                bitOffset = 0
                byteOffset += 1
                hasByte = false
            }

            return bit != 0
        }
    }
}
