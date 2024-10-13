//
//  ObjCHeaderInfoRW.swift
//  
//
//  Created by p-x9 on 2024/10/14
//  
//

import Foundation

public protocol ObjCHeaderInfoRWProtocol {
    /// A boolean value that indicates whether objc image is already loaded or not
    var isLoaded: Bool { get }
    /// A boolean value that indicates whether all objc classes contained in objc image are realized
    var isAllClassesRelized: Bool { get }
}

public struct ObjCHeaderInfoRW64: LayoutWrapper, ObjCHeaderInfoRWProtocol {
    public typealias Layout = header_info_rw_64

    public var layout: Layout

    public var isLoaded: Bool { layout.isLoaded == 1 }
    public var isAllClassesRelized: Bool { layout.allClassesRealized == 1 }
}

public struct ObjCHeaderInfoRW32: LayoutWrapper, ObjCHeaderInfoRWProtocol {
    public typealias Layout = header_info_rw_32

    public var layout: Layout

    public var isLoaded: Bool { layout.isLoaded == 1 }
    public var isAllClassesRelized: Bool { layout.allClassesRealized == 1 }
}
