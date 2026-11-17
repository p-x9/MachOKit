//
//  MachOFileDataTests.swift
//  MachOKit
//
//

import XCTest
@_spi(Support) @testable import MachOKit

final class MachOFileDataTests: XCTestCase {
    private let url = URL(fileURLWithPath: "/bin/ls")

    private func headerStartOffset() throws -> Int {
        switch try MachOKit.loadFromFile(url: url) {
        case let .fat(fat): return Int(fat.arches[0].offset)
        case .machO: return 0
        }
    }

    func testMatchesFileOpenedByURL() throws {
        let offset = try headerStartOffset()
        let fromURL = try MachOFile(url: url, headerStartOffset: offset)
        let data = try Data(contentsOf: url)
        let fromData = try MachOFile(data: data, headerStartOffset: offset)

        XCTAssertEqual(
            fromData.loadCommands.map(\.type),
            fromURL.loadCommands.map(\.type)
        )
        XCTAssertEqual(
            fromData.symbols.map(\.name),
            fromURL.symbols.map(\.name)
        )
        XCTAssertEqual(
            fromData.dependencies.map(\.dylib.name),
            fromURL.dependencies.map(\.dylib.name)
        )

        XCTAssertNil(fromData.url)
        XCTAssertEqual(fromData.imagePath, "")
        XCTAssertNil(fromData.cache)
        XCTAssertEqual(fromData.backingData, data)
        XCTAssertNil(fromURL.backingData)

        let named = try MachOFile(
            data: data,
            imagePath: "archive.zip/ls",
            headerStartOffset: offset
        )
        XCTAssertEqual(named.imagePath, "archive.zip/ls")
    }

    func testTooShortInputThrows() throws {
        let offset = try headerStartOffset()
        let data = try Data(contentsOf: url)
        let headerSize = try MachOFile(data: data, headerStartOffset: offset).headerSize
        let header = data.subdata(in: offset ..< offset + headerSize)

        XCTAssertThrowsError(try MachOFile(data: Data()))
        XCTAssertThrowsError(try MachOFile(data: header.prefix(3)))
        // A complete header whose load commands are missing
        XCTAssertThrowsError(try MachOFile(data: header))
        XCTAssertThrowsError(try MachOFile(data: data, headerStartOffset: data.count))

        let short = FileManager.default.temporaryDirectory
            .appendingPathComponent("MachOFileDataTests-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: short) }
        try Data([0xcf, 0xfa, 0xed]).write(to: short)
        XCTAssertThrowsError(try MachOFile(url: short))
    }
}
