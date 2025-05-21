//
//  SwiftOptimization.swift
//
//
//  Created by p-x9 on 2024/07/05
//  
//

import Foundation
import MachOKitC

public struct SwiftOptimization: LayoutWrapper {
    public typealias Layout = swift_optimization

    public var layout: Layout
}

extension SwiftOptimization {
    public func hasProperty<Value>(_ keyPath: KeyPath<Layout, Value>) -> Bool {
        switch keyPath {
        case \.prespecializationDataCacheOffset:
            return layout.version >= 2
        case \.prespecializedMetadataHashTableCacheOffsets:
            return layout.version >= 3
        default:
            return true
        }
    }
}
