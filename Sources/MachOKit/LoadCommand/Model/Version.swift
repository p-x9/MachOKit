//
//  Version.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public struct Version {
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

extension Version: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(major).\(minor).\(patch)"
    }
}

