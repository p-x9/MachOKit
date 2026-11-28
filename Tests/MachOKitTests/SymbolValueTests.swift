import XCTest
import FileIO
@testable import MachOKit

final class SymbolValueTests: XCTestCase {
    private let highValue: UInt64 = 0x8000_0004_FFFF_FFFF

    private func record32(type: UInt8, value: UInt32, section: UInt8 = 0) -> Nlist {
        var layout = nlist()
        layout.n_un.n_strx = 1
        layout.n_type = type
        layout.n_sect = section
        layout.n_value = value
        return Nlist(layout: layout)
    }

    private func record64(type: UInt8, value: UInt64, section: UInt8 = 0) -> Nlist64 {
        var layout = nlist_64()
        layout.n_un.n_strx = 1
        layout.n_type = type
        layout.n_sect = section
        layout.n_value = value
        return Nlist64(layout: layout)
    }

    func testValueInterpretationForBothLayouts() {
        let cases: [(type: UInt8, section: UInt8, raw: UInt64, expected: SymbolValue)] = [
            (UInt8(N_SECT | N_EXT), 1, 0x1234, .sect(value: 0x1234)),
            (UInt8(N_ABS | N_EXT), 0, 0, .abs(value: 0)),
            (UInt8(N_ABS), 0, UInt64(UInt32.max), .abs(value: UInt64(UInt32.max))),
            (UInt8(N_UNDF | N_EXT), 0, 0, .undf(value: 0)),
            (UInt8(N_UNDF | N_EXT), 0, 128, .common(size: 128)),
            // A non-external undefined symbol is not a common symbol.
            (UInt8(N_UNDF), 0, 128, .undf(value: 128)),
            // A section number also prevents classification as a common symbol.
            (UInt8(N_UNDF | N_EXT), 1, 128, .undf(value: 128)),
            (UInt8(N_PBUD | N_EXT), 0, 99, .pbud(value: 99)),
            (UInt8(N_INDR | N_EXT), 0, 42, .indr(stringTableIndex: 42)),
            // STAB takes priority even when N_TYPE resembles a section symbol.
            (0x2e, 1, 32, .stab(type: 0x2e, value: 32)),
            // Unrecognized STAB codes must not become ordinary symbols.
            (0xe3, 0, 64, .stab(type: 0xe3, value: 64)),
            (0x17, 0, 55, .unknown(type: 0x17, value: 55)),
        ]

        for test in cases {
            let records: [any NlistProtocol] = [
                record32(type: test.type, value: UInt32(test.raw), section: test.section),
                record64(type: test.type, value: test.raw, section: test.section),
            ]
            for record in records {
                XCTAssertEqual(record.rawValue, test.raw)
                XCTAssertEqual(record.value, test.expected)
                XCTAssertEqual(record.isDebugSymbol, Int32(test.type) & N_STAB != 0)
            }
        }
    }

    func testFullValueRangeAndLayoutMutation() {
        let values: [UInt64] = [
            0, UInt64(Int32.max) + 1, UInt64(UInt32.max),
            UInt64(Int64.max) + 1, highValue, UInt64.max,
        ]
        for value in values {
            let record = record64(type: UInt8(N_ABS), value: value)
            XCTAssertEqual(record.rawValue, value)
            XCTAssertEqual(record.value, .abs(value: value))
        }

        var record = record64(type: UInt8(N_ABS), value: highValue)
        record.layout.n_type = UInt8(N_INDR)
        record.layout.n_value = UInt64.max
        XCTAssertEqual(record.rawValue, UInt64.max)
        XCTAssertEqual(record.value, .indr(stringTableIndex: UInt64.max))
    }

    private func check(
        _ table: some _SymbolTableProtocol,
        expectedValue: UInt64,
        expectedOffset: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let record = table.wrappedNlist(at: 0)
        let symbol: any SymbolProtocol = table.symbol(at: 0, nlist: record)
        XCTAssertEqual(record.rawValue, expectedValue, file: file, line: line)
        XCTAssertEqual(table.offset(of: record), expectedOffset, file: file, line: line)
        XCTAssertEqual(symbol.offset, expectedOffset, file: file, line: line)
        XCTAssertEqual(symbol.rawValue, expectedValue, file: file, line: line)
        XCTAssertEqual(symbol.value, .abs(value: expectedValue), file: file, line: line)
        XCTAssertFalse(symbol.isDebugSymbol, file: file, line: line)
    }

    func testImageReadersPreserveRawValuesWithBaseAdjustment() {
        let strings: [CChar] = [0, 115, 0]
        // Exercise wrapping of the legacy offset independently of the raw value.
        let base = Int.max
        var layout32 = record32(type: UInt8(N_ABS | N_EXT), value: .max).layout
        var layout64 = record64(type: UInt8(N_ABS | N_EXT), value: highValue).layout

        strings.withUnsafeBufferPointer { strings in
            withUnsafePointer(to: &layout32) { pointer in
                let table = MachOImage.Symbols(
                    stringBase: strings.baseAddress!, addressStart: base,
                    symbols: pointer, numberOfSymbols: 1
                )
                XCTAssertEqual(Array(table).map(\.rawValue), [UInt64(UInt32.max)])
                XCTAssertEqual(table[0].value, .abs(value: UInt64(UInt32.max)))
                XCTAssertEqual(table[0].name, "s")
                check(table, expectedValue: UInt64(UInt32.max),
                      expectedOffset: base &+ Int(truncatingIfNeeded: UInt32.max))
            }
            withUnsafePointer(to: &layout64) { pointer in
                let table = MachOImage.Symbols64(
                    stringBase: strings.baseAddress!, addressStart: base,
                    symbols: pointer, numberOfSymbols: 1
                )
                XCTAssertEqual(Array(table).map(\.rawValue), [highValue])
                XCTAssertEqual(table[0].value, .abs(value: highValue))
                XCTAssertEqual(table[0].name, "s")
                check(table, expectedValue: highValue,
                      expectedOffset: base &+ Int(truncatingIfNeeded: highValue))
            }
        }
    }

    func testFileReadersPreserveRawValuesIncludingSwappedLayouts() throws {
        let strings: [UInt8] = [0, 115, 0]
        for swapped in [false, true] {
            var layout32 = record32(type: UInt8(N_ABS | N_EXT), value: .max).layout
            var layout64 = record64(type: UInt8(N_ABS | N_EXT), value: highValue).layout
            if swapped {
                layout32.n_un.n_strx = layout32.n_un.n_strx.byteSwapped
                layout32.n_value = layout32.n_value.byteSwapped
                layout64.n_un.n_strx = layout64.n_un.n_strx.byteSwapped
                layout64.n_value = layout64.n_value.byteSwapped
            }
            var data = Data(strings)
            withUnsafeBytes(of: layout32) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: layout64) { data.append(contentsOf: $0) }
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("SymbolValueTests-\(UUID().uuidString)")
            try data.write(to: url)
            defer { try? FileManager.default.removeItem(at: url) }

            let file = try MachOFile.File.open(url: url, isWritable: false)
            let stringSlice = try file.fileSlice(offset: 0, length: strings.count)
            let table32 = MachOFile.Symbols(
                symtab: nil, stringsSlice: stringSlice,
                symbolsSlice: try file.fileSlice(offset: strings.count, length: Nlist.layoutSize),
                numberOfSymbols: 1, isSwapped: swapped
            )
            let table64 = MachOFile.Symbols64(
                symtab: nil, stringsSlice: stringSlice,
                symbolsSlice: try file.fileSlice(
                    offset: strings.count + Nlist.layoutSize, length: Nlist64.layoutSize
                ),
                numberOfSymbols: 1, isSwapped: swapped
            )
            XCTAssertEqual(Array(table32).map(\.rawValue), [UInt64(UInt32.max)])
            XCTAssertEqual(table32[0].value, .abs(value: UInt64(UInt32.max)))
            XCTAssertEqual(table32[0].name, "s")
            check(table32, expectedValue: UInt64(UInt32.max),
                  expectedOffset: Int(truncatingIfNeeded: UInt32.max))
            XCTAssertEqual(Array(table64).map(\.rawValue), [highValue])
            XCTAssertEqual(table64[0].value, .abs(value: highValue))
            XCTAssertEqual(table64[0].name, "s")
            check(table64, expectedValue: highValue,
                  expectedOffset: Int(truncatingIfNeeded: highValue))
        }
    }
}
