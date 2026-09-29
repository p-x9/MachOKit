import XCTest
@testable import MachOKit

#if canImport(Darwin)
/// Covers what `CPU.current` reports for the machine the tests run on.
///
/// An Intel Mac, and an x86_64 process translated by Rosetta, reports
/// `hw.cputype` as `CPU_TYPE_X86` (7) without the ABI64 bit, next to
/// `hw.cpu64bit_capable` = 1. The 64-bit type has to be recovered from that
/// pair; `hw.cputype` alone makes every such host look like i386.
final class CPUCurrentTests: XCTestCase {
    /// The host CPU matches the architecture this test binary was built for.
    ///
    /// Run the suite as x86_64 (`swift test --arch x86_64`, under Rosetta on
    /// Apple silicon) to cover the Intel path.
    func testCurrentTypeMatchesTheRunningArchitecture() throws {
        let current = try XCTUnwrap(CPU.current)
        #if arch(x86_64)
        XCTAssertEqual(current.type, .x86_64)
        #elseif arch(arm64)
        XCTAssertEqual(current.type, .arm64)
        #endif
    }
}
#endif
