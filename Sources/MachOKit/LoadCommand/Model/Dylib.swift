//
//  Dylib.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public struct Dylib {
    /// library's path name
    public var name: String

    /// library's build time stamp
    public var timestamp: Date

    /// library's current version number
    public var currentVersion: Version

    /// library's compatibility vers number
    public var compatibilityVersion: Version
}
