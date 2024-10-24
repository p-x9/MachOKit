//
//  DependedDylib.swift
//
//
//  Created by p-x9 on 2024/02/03.
//  
//

import Foundation

public struct DependedDylib {
    public enum DependType {
        case load
        case weakLoad
        case reexport
        case upwardLoad
        case lazyLoad
    }

    public let dylib: Dylib
    public let type: DependType
}
