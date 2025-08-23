//
//  Version.swift
//
//
//  Created by p-x9 on 2023/11/29.
//
//

import Foundation

public struct Version: Equatable, Sendable {
    public let major: Int
    public let minor: Int
    public let patch: Int
}

extension Version {
    init(_ version: UInt32) {
        self.init(
            major: Int((version & 0xFFFF0000) >> 16),
            minor: Int((version & 0x0000FF00) >> 8),
            patch: Int(version & 0x000000FF)
        )
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}

extension Version: Comparable {
    public static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }
        return false
    }
}

public struct SourceVersion {
    public let a: Int
    public let b: Int
    public let c: Int
    public let d: Int
    public let e: Int
}

extension SourceVersion {
    init(_ version: UInt64) {
        self.init(
            a: Int((version >> 40) & 0xFFFFFF),
            b: Int((version >> 30) & 0x3FF),
            c: Int((version >> 20) & 0x3FF),
            d: Int((version >> 10) & 0x3FF),
            e: Int((version >> 0) & 0x3FF)
        )
    }
}

extension SourceVersion: CustomStringConvertible {
    public var description: String {
        var components = [a, b, c, d, e]
        if e == 0 { _ = components.popLast() }
        if e == 0 && d == 0 { _ = components.popLast() }
        return components.map(String.init).joined(separator: ".")
    }
}
