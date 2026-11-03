//
//  DependedDylib.swift
//
//
//  Created by p-x9 on 2024/02/03.
//
//

import Foundation

public struct DependedDylib: Sendable {
    public enum DependType: Sendable {
        case load
        case weakLoad
        case reexport
        case upwardLoad
        case lazyLoad
    }

    public let dylib: Dylib
    public let type: DependType
    public let useFlags: DylibUseFlags

    /// Creates a dependency with its load kind and use flags.
    public init(
        dylib: Dylib,
        type: DependType,
        useFlags: DylibUseFlags = []
    ) {
        self.dylib = dylib
        self.type = type
        self.useFlags = useFlags
    }
}
