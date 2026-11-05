import XCTest
import FileIO
@testable import MachOKit

/// An `N_ABS` symbol's `n_value` is a constant, not an address, and may use
/// all 64 bits. macOS 27's libswiftCore exports `_swiftImmortalRefCount`
/// (`N_ABS | N_EXT`) with `n_value` 0x80000004ffffffff; widening that to `Int`
/// with `numericCast` traps, so reading the symbol table of such an image
/// crashed. Both readers must keep the value's bit pattern instead.
final class AbsoluteSymbolValueTests: XCTestCase {
    private static let symbolName = "_swiftImmortalRefCount"
    private static let absoluteValue: UInt64 = 0x8000_0004_FFFF_FFFF

    /// `"\0_swiftImmortalRefCount\0"`
    private static func makeStrings() -> [UInt8] {
        [0] + Array(symbolName.utf8) + [0]
    }

    /// One `nlist_64` naming the string at index 1.
    private static func makeSymbols() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: 16)
        func write<Value: FixedWidthInteger>(_ value: Value, at offset: Int) {
            withUnsafeBytes(of: value.littleEndian) { source in
                for (index, byte) in source.enumerated() {
                    bytes[offset + index] = byte
                }
            }
        }
        write(UInt32(1), at: 0) // n_strx
        write(UInt8(0x03), at: 4) // n_type: N_ABS | N_EXT
        write(UInt8(0), at: 5) // n_sect: NO_SECT
        write(UInt16(0), at: 6) // n_desc
        write(absoluteValue, at: 8) // n_value
        return bytes
    }

    func testAbsoluteValueKeepsItsBitsInAnImage() {
        let strings = Self.makeStrings()
        let symbols = Self.makeSymbols()
        strings.withUnsafeBytes { stringBytes in
            symbols.withUnsafeBytes { symbolBytes in
                let symbolTable = MachOImage.Symbols64(
                    stringBase: stringBytes.baseAddress!.assumingMemoryBound(to: CChar.self),
                    addressStart: 0,
                    symbols: symbolBytes.baseAddress!.assumingMemoryBound(to: nlist_64.self),
                    numberOfSymbols: 1
                )
                let iteratedSymbol = Array(symbolTable).first
                XCTAssertEqual(iteratedSymbol?.name, Self.symbolName)
                XCTAssertEqual(iteratedSymbol.map { UInt(bitPattern: $0.offset) }, 0x8000_0004_FFFF_FFFF)
                XCTAssertEqual(UInt(bitPattern: symbolTable[symbolTable.startIndex].offset), 0x8000_0004_FFFF_FFFF)
            }
        }
    }

    func testAbsoluteValueKeepsItsBitsInAFile() throws {
        let strings = Self.makeStrings()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AbsoluteSymbolValueTests-\(UUID().uuidString)")
        try Data(strings + Self.makeSymbols()).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let file = try MachOFile.File.open(url: url, isWritable: false)
        let symbolTable = MachOFile.Symbols64(
            symtab: nil,
            stringsSlice: try file.fileSlice(offset: 0, length: strings.count),
            symbolsSlice: try file.fileSlice(offset: strings.count, length: 16),
            numberOfSymbols: 1,
            isSwapped: false
        )
        let iteratedSymbol = Array(symbolTable).first
        XCTAssertEqual(iteratedSymbol?.name, Self.symbolName)
        XCTAssertEqual(iteratedSymbol.map { UInt(bitPattern: $0.offset) }, 0x8000_0004_FFFF_FFFF)
        XCTAssertEqual(UInt(bitPattern: symbolTable[symbolTable.startIndex].offset), 0x8000_0004_FFFF_FFFF)
    }
}
