//
//  ObjCOptimization.swift
//
//
//  Created by p-x9 on 2024/05/29
//  
//

import Foundation
import MachOKitC

public struct ObjCOptimization: LayoutWrapper {
    public typealias Layout = objc_optimization

    public var layout: Layout
}

