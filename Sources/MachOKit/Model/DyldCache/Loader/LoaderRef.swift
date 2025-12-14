//
//  LoaderRef.swift
//
//
//  Created by p-x9 on 2024/07/10
//  
//

import Foundation

public struct LoaderRef: LayoutWrapper, Sendable {
    public typealias Layout = loader_ref

    public var layout: Layout
}

extension LoaderRef {
    public var index: Int {
        numericCast(layout.index)
    }

    public var isApp: Bool {
        layout.app == 1
    }

    public var  isDylib: Bool {
        layout.app == 0
    }
}
