//
//  Dylib.swift
//
//
//  Created by p-x9 on 2023/11/29.
//
//

import Foundation

public struct Dylib: Sendable {
    /// library's path name
    public var name: String

    /// library's build time stamp
    public var timestamp: Date

    /// library's current version number
    public var currentVersion: Version

    /// library's compatibility vers number
    public var compatibilityVersion: Version
}

extension Dylib {
    /// A boolean value that indicates whether self is loaded from `dylib_use_command`
    public var isFromDylibUseCommand: Bool {
        timestamp.timeIntervalSince1970 == TimeInterval(DYLIB_USE_MARKER)
    }
}
