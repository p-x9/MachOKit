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

    var layout: Layout { get }
}

extension LayoutWrapper {
    public subscript<Value>(dynamicMember keyPath: KeyPath<Layout, Value>) -> Value {
        layout[keyPath: keyPath]
    }
}