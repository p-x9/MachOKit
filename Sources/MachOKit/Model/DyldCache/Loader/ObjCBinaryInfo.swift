//
//  ObjCBinaryInfo.swift
//  MachOKit
//
//  Created by p-x9 on 2024/11/16
//  
//

import Foundation

public struct ObjCBinaryInfo: LayoutWrapper, Sendable {
    public typealias Layout = objc_binary_info

    public var layout: Layout
}
