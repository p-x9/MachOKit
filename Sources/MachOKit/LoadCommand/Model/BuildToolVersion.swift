//
//  BuildToolVersion.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public struct BuildToolVersion: LayoutWrapper {
    public let layout: build_tool_version

    public var tool: Tool? {
        .init(rawValue: Int32(layout.tool))
    }

    public var version: Version {
        .init(layout.version)
    }
}
