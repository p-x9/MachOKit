//
//  TrieNodeBoundsTests.swift
//  MachOKit
//

import XCTest
@_spi(Support) @testable import MachOKit

final class TrieNodeBoundsTests: XCTestCase {
    // offset 0:  root, children: "_" -> 4
    // offset 4:  "_", children: "a" -> 11, "b" -> 15
    // offset 11: "_a", regular export at 0x10
    // offset 15: "_b", reexport from ordinal 1 as "_c"
    // offset 21: (unreferenced) stub and resolver
    private let trie: [UInt8] = [
        0x00, 0x01, 0x5F, 0x00, 0x04,
        0x00, 0x02, 0x61, 0x00, 0x0B, 0x62, 0x00, 0x0F,
        0x02, 0x00, 0x10, 0x00,
        0x05, 0x08, 0x01, 0x5F, 0x63, 0x00, 0x00,
        0x03, 0x10, 0x20, 0x30, 0x00
    ]

    private func read(
        _ bytes: [UInt8],
        trieSize: Int? = nil,
        offset: Int = 0
    ) -> (entry: ExportTrieEntry?, nextOffset: Int) {
        var nextOffset = offset
        let entry: ExportTrieEntry? = bytes.withUnsafeBufferPointer {
            .readNext(
                basePointer: $0.baseAddress!,
                trieSize: trieSize ?? bytes.count,
                nextOffset: &nextOffset
            )
        }
        return (entry, nextOffset)
    }
}

// MARK: - valid
extension TrieNodeBoundsTests {
    func testReadNextDecodesValidNodes() throws {
        var (entry, nextOffset) = read(trie)
        var node = try XCTUnwrap(entry)
        XCTAssertEqual(node.offset, 0)
        XCTAssertEqual(node.terminalSize, 0)
        XCTAssertNil(node.content)
        XCTAssertEqual(node.children.map(\.label), ["_"])
        XCTAssertEqual(node.children.map(\.offset), [4])
        XCTAssertEqual(nextOffset, 5)

        (entry, nextOffset) = read(trie, offset: 5)
        node = try XCTUnwrap(entry)
        XCTAssertEqual(node.offset, 5)
        XCTAssertFalse(node.isTerminal)
        XCTAssertEqual(node.children.map(\.label), ["a", "b"])
        XCTAssertEqual(node.children.map(\.offset), [11, 15])
        XCTAssertEqual(nextOffset, 13)

        (entry, nextOffset) = read(trie, offset: 13)
        node = try XCTUnwrap(entry)
        XCTAssertEqual(node.terminalSize, 2)
        XCTAssertEqual(node.content?.flags?.rawValue, 0)
        XCTAssertEqual(node.content?.symbolOffset, 0x10)
        XCTAssertTrue(node.children.isEmpty)
        XCTAssertEqual(nextOffset, 17)

        (entry, nextOffset) = read(trie, offset: 17)
        node = try XCTUnwrap(entry)
        XCTAssertEqual(node.terminalSize, 5)
        XCTAssertEqual(node.content?.flags, .reexport)
        XCTAssertEqual(node.content?.ordinal, 1)
        XCTAssertEqual(node.content?.importedName, "_c")
        XCTAssertNil(node.content?.symbolOffset)
        XCTAssertEqual(nextOffset, 24)

        (entry, nextOffset) = read(trie, offset: 24)
        node = try XCTUnwrap(entry)
        XCTAssertEqual(node.terminalSize, 3)
        XCTAssertEqual(node.content?.flags, .stub_and_resolver)
        XCTAssertEqual(node.content?.stub, 0x20)
        XCTAssertEqual(node.content?.resolver, 0x30)
        XCTAssertEqual(nextOffset, trie.count)

        XCTAssertNil(read(trie, offset: trie.count).entry)
        XCTAssertNil(read(trie, offset: -1).entry)
    }
}

// MARK: - malformed
extension TrieNodeBoundsTests {
    func testReadNextRejectsTruncatedTerminalSize() {
        XCTAssertNil(read([0x80]).entry)
        XCTAssertNil(read([0x80, 0x80]).entry)
        // terminated only outside of the trie
        XCTAssertNil(read([0x80, 0x00, 0x00], trieSize: 1).entry)
    }

    func testReadNextRejectsOverflowingTerminalSize() {
        // fits in 64 bits, but not in the trie (and not in `Int`)
        XCTAssertNil(read([UInt8](repeating: 0xFF, count: 9) + [0x01, 0x00]).entry)
    }

    func testReadNextRejectsTruncatedTerminal() {
        // terminal payload is longer than the trie
        XCTAssertNil(read([0x05, 0x00]).entry)
        XCTAssertNil(read([0x02, 0x00, 0x10, 0x00], trieSize: 2).entry)
        // ULEB128 in the payload is not terminated inside the trie
        XCTAssertNil(read([0x02, 0x00, 0x80]).entry)
        // flags do not fit in `ExportSymbolFlags.RawValue`
        XCTAssertNil(read([0x06, 0x80, 0x80, 0x80, 0x80, 0x08, 0x00, 0x00]).entry)
    }

    func testReadNextRejectsTerminalContentBeyondTerminalSize() {
        // reexport name is not terminated inside the terminal payload
        XCTAssertNil(read([0x03, 0x08, 0x00, 0x61, 0x00]).entry)
        // reexport name is not terminated inside the trie
        XCTAssertNil(read([0x03, 0x08, 0x00, 0x61]).entry)
        // resolver offset lies behind the terminal payload
        XCTAssertNil(read([0x02, 0x10, 0x01, 0x00]).entry)
    }

    func testReadNextRejectsChildLabelWithoutTerminator() {
        XCTAssertNil(read([0x00, 0x01, 0x61]).entry)
        XCTAssertNil(read([0x00, 0x01]).entry)
        // terminator exists, but outside of the trie
        XCTAssertNil(read([0x00, 0x01, 0x61, 0x00, 0x00], trieSize: 3).entry)
    }

    func testReadNextRejectsMalformedChildOffset() {
        // truncated
        XCTAssertNil(read([0x00, 0x01, 0x61, 0x00]).entry)
        XCTAssertNil(read([0x00, 0x01, 0x61, 0x00, 0x80]).entry)
        // beyond the trie
        XCTAssertNil(read([0x00, 0x01, 0x61, 0x00, 0x05]).entry)
        XCTAssertNil(read([0x00, 0x01, 0x61, 0x00, 0xFF, 0x7F]).entry)
        // last valid offset
        XCTAssertNotNil(read([0x00, 0x01, 0x61, 0x00, 0x04]).entry)
    }

    func testTrieTreeStopsAtMalformedNode() {
        let bytes: [UInt8] = [0x00, 0x01, 0x61, 0x00, 0x05, 0x00, 0x01, 0x62]
        let tree = DataTrieTree<ExportTrieNodeContent>(data: Data(bytes))
        XCTAssertEqual(Array(tree).map(\.offset), [0])
        XCTAssertEqual(tree.entries.map(\.offset), [0])
        XCTAssertNil(tree.element(atOffset: 5))
        XCTAssertNil(tree._search(by: "ab"))
    }

    func testTrieTreeStopsAtCycle() {
        // child "a" points back to the root
        let tree = DataTrieTree<ExportTrieNodeContent>(data: Data([0x00, 0x01, 0x61, 0x00, 0x00]))
        XCTAssertEqual(tree.entries.map(\.offset), [0])
        XCTAssertTrue(tree.exportedSymbols.isEmpty)
        XCTAssertNil(tree._search(by: "aa"))

        // empty label pointing back to the root
        let emptyLabel = DataTrieTree<ExportTrieNodeContent>(data: Data([0x00, 0x01, 0x00, 0x00]))
        XCTAssertNil(emptyLabel._search(by: "a"))
        XCTAssertTrue(emptyLabel._search(byKeyPrefix: "a").isEmpty)
    }
}

// MARK: - traversal
extension TrieNodeBoundsTests {
    func testTrieTreeVisitsSharedNodeViaEveryParent() {
        // offset 0: root, children: "a" -> 8, "b" -> 8
        // offset 8: regular export at 0x10
        let bytes: [UInt8] = [
            0x00, 0x02, 0x61, 0x00, 0x08, 0x62, 0x00, 0x08,
            0x02, 0x00, 0x10, 0x00
        ]
        let tree = DataTrieTree<ExportTrieNodeContent>(data: Data(bytes))
        XCTAssertEqual(tree.entries.map(\.offset), [0, 8, 8])
        XCTAssertEqual(tree.exportedSymbols.map(\.name), ["a", "b"])
        XCTAssertEqual(tree.exportedSymbols.map(\.offset), [0x10, 0x10])
    }

    func testTrieTreeStopsAtCycleBelowRoot() {
        // offset 0: root, children: "a" -> 5
        // offset 5: "a", terminal 0x10, children: "b" -> 0 (root), "c" -> 5 (self)
        let bytes: [UInt8] = [
            0x00, 0x01, 0x61, 0x00, 0x05,
            0x02, 0x00, 0x10, 0x02, 0x62, 0x00, 0x00, 0x63, 0x00, 0x05
        ]
        let tree = DataTrieTree<ExportTrieNodeContent>(data: Data(bytes))
        XCTAssertEqual(tree.entries.map(\.offset), [0, 5])
        XCTAssertEqual(tree.exportedSymbols.map(\.name), ["a"])
    }

    func testTrieTreeHandlesDeepChain() {
        // Each node has a single child "a" with a 4-byte padded ULEB128 offset,
        // so node `i` lives at offset `8 * i`. The last node is a terminal.
        let depth = 200_000
        var bytes: [UInt8] = []
        bytes.reserveCapacity(depth * 8 + 4)
        for i in 0..<depth {
            let next = UInt32(8 * (i + 1))
            bytes += [0x00, 0x01, 0x61, 0x00]
            bytes += [
                UInt8(next & 0x7F) | 0x80,
                UInt8((next >> 7) & 0x7F) | 0x80,
                UInt8((next >> 14) & 0x7F) | 0x80,
                UInt8((next >> 21) & 0x7F)
            ]
        }
        bytes += [0x02, 0x00, 0x10, 0x00]

        let tree = DataTrieTree<ExportTrieNodeContent>(data: Data(bytes))
        XCTAssertEqual(tree.entries.count, depth + 1)
        let symbols = tree.exportedSymbols
        XCTAssertEqual(symbols.count, 1)
        XCTAssertEqual(symbols.first?.name, String(repeating: "a", count: depth))
        XCTAssertEqual(symbols.first?.offset, 0x10)
    }
}
