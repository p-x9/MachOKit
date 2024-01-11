//
//  LayoutWrapper.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

@dynamicMemberLookup
public protocol LayoutWrapper {
    associatedtype Layout

    var layout: Layout { get set }
}

extension LayoutWrapper {
    public subscript<Value>(dynamicMember keyPath: KeyPath<Layout, Value>) -> Value {
        layout[keyPath: keyPath]
    }
}

extension LayoutWrapper {
    static var layoutSize: Int {
        MemoryLayout<Layout>.size
    }

    var layoutSize: Int {
        MemoryLayout<Layout>.size
    }
}

extension LayoutWrapper {
    static func layoutOffset(of key: PartialKeyPath<Layout>) -> Int {
        MemoryLayout<Layout>.offset(of: key)!
    }

    func layoutOffset(of key: PartialKeyPath<Layout>) -> Int {
        MemoryLayout<Layout>.offset(of: key)!
    }
}

