//
//  PerfectHashTests.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/20
//
//

import XCTest
@testable import MachOKit

final class PerfectHashTests: XCTestCase {
    // Expected values are computed with `objc::lookup8` in dyld/common/PerfectHash.cpp
    let vectors: [(key: String, level: UInt64, hash: UInt64)] = [
        ("", 0x0, 0x8db63936938575bf),
        ("a", 0x0, 0x1d48fd74d88633ac),
        ("alloc", 0x0, 0x3086213c99808130),
        ("init", 0x0, 0x784d257f34dc9341),
        ("description", 0x0, 0xe2861e4b4175b1ad),
        ("abcdefghijklmnopqrstuvw", 0x0, 0xdd0ace75e7ef90e4),
        ("abcdefghijklmnopqrstuvwx", 0x0, 0xa96a1b599125e179),
        ("initWithContentsOfURL:options:error:", 0x0, 0xfd7c4bca33255263),
        ("application:didFinishLaunchingWithOptions:", 0x0, 0xd9d0f1c542a7c209),
        ("", 0x35e2aa2e7e47a86, 0xdc6bf40df8e9cfc7),
        ("a", 0x35e2aa2e7e47a86, 0x7bca7088998a29f9),
        ("alloc", 0x35e2aa2e7e47a86, 0x41ea3feee2904511),
        ("init", 0x35e2aa2e7e47a86, 0xe4222ac6474a301f),
        ("description", 0x35e2aa2e7e47a86, 0x644f578d5a40f9fc),
        ("abcdefghijklmnopqrstuvw", 0x35e2aa2e7e47a86, 0x4fb66ee29254f67b),
        ("abcdefghijklmnopqrstuvwx", 0x35e2aa2e7e47a86, 0x5af32303fa0d5958),
        ("initWithContentsOfURL:options:error:", 0x35e2aa2e7e47a86, 0x625c374ae3d5f04f),
        ("application:didFinishLaunchingWithOptions:", 0x35e2aa2e7e47a86, 0xb78cefcb939eac5f),
    ]

    func testLookup8() {
        for vector in vectors {
            XCTAssertEqual(
                PerfectHash.lookup8(vector.key, level: vector.level),
                vector.hash,
                "\(vector.key), level: \(vector.level)"
            )
        }
    }
}
