//
//  BuildToolVersion.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public struct BuildToolVersion: LayoutWrapper, Sendable {
    public var layout: build_tool_version

    /// Creates a wrapper for the given C layout.
    public init(layout: build_tool_version) {
        self.layout = layout
    }

    public var tool: Tool? {
        .init(rawValue: Int32(layout.tool))
    }

    public var version: Version {
        .init(layout.version)
    }
}
