import XCTest
import MachOKitC
@testable import MachOKit

/// `dyld_chained_import_addend.addend` is an `int32_t`, and
/// `dyld_chained_import_addend64.addend` is declared as `uint64_t` but holds a
/// two's complement value: dyld adds it to the symbol address with wrapping
/// arithmetic, so `-8` is stored as `0xFFFF_FFFF_FFFF_FFF8`.
///
/// Converting that raw value with `numericCast` trapped
/// ("Not enough bits to represent the passed value") for every negative
/// 64-bit addend.
final class DyldChainedImportAddendTests: XCTestCase {
    func testGeneralImportHasNoAddend() {
        let general = DyldChainedImportGeneral(
            layout: .init(lib_ordinal: 1, weak_import: 0, name_offset: 0x10)
        )

        XCTAssertEqual(general.addend, 0)
        XCTAssertEqual(DyldChainedImport.general(general).info.addend, 0)
    }

    func testAddendImportKeepsPositiveAddend() {
        let addend = makeAddend(0x1234)

        XCTAssertEqual(addend.addend, 0x1234)
        XCTAssertEqual(DyldChainedImport.addend(addend).info.addend, 0x1234)
    }

    func testAddendImportKeepsNegativeAddend() {
        XCTAssertEqual(makeAddend(-8).addend, -8)
        XCTAssertEqual(makeAddend(.min).addend, Int(Int32.min))
        XCTAssertEqual(DyldChainedImport.addend(makeAddend(-8)).info.addend, -8)
    }

    func testAddend64ImportKeepsPositiveAddend() {
        let addend = makeAddend64(0x1_0000_0000)

        XCTAssertEqual(Int64(addend.addend), 0x1_0000_0000)
        XCTAssertEqual(
            Int64(DyldChainedImport.addend64(addend).info.addend),
            0x1_0000_0000
        )
        XCTAssertEqual(
            Int64(makeAddend64(0x7FFF_FFFF_FFFF_FFFF).addend),
            Int64.max
        )
    }

    func testAddend64ImportKeepsNegativeAddend() {
        let addend = makeAddend64(0xFFFF_FFFF_FFFF_FFF8)

        XCTAssertEqual(addend.addend, -8)
        XCTAssertEqual(DyldChainedImport.addend64(addend).info.addend, -8)
        XCTAssertEqual(
            Int64(makeAddend64(0x8000_0000_0000_0000).addend),
            Int64.min
        )
    }

    func testAddend64ImportKeepsOtherFields() {
        let addend = makeAddend64(0xFFFF_FFFF_FFFF_FFF8)

        XCTAssertEqual(addend.libraryOrdinal, 1)
        XCTAssertFalse(addend.isWeakImport)
        XCTAssertEqual(addend.nameOffset, 0x10)
        XCTAssertEqual(addend.layout.addend, 0xFFFF_FFFF_FFFF_FFF8)
    }
}

extension DyldChainedImportAddendTests {
    private func makeAddend(_ addend: Int32) -> DyldChainedImportAddend {
        .init(
            layout: .init(
                lib_ordinal: 1,
                weak_import: 0,
                name_offset: 0x10,
                addend: addend
            )
        )
    }

    private func makeAddend64(_ addend: UInt64) -> DyldChainedImportAddend64 {
        .init(
            layout: .init(
                lib_ordinal: 1,
                weak_import: 0,
                reserved: 0,
                name_offset: 0x10,
                addend: addend
            )
        )
    }
}
