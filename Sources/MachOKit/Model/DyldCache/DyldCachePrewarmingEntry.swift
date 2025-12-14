//
//  DyldCachePrewarmingEntry.swift
//  MachOKit
//
//  Created by p-x9 on 2025/05/13
//  
//

import Foundation
import MachOKitC

public struct DyldCachePrewarmingEntry: LayoutWrapper, Sendable {
    public typealias Layout = dyld_prewarming_entry

    public var layout: Layout
}
