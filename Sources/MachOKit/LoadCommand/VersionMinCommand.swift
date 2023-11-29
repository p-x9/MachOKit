//
//  VersionMinCommand.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public struct VersionMinCommand: LoadCommandWrapper {
    public typealias Layout = version_min_command

    public var layout: version_min_command

    public var offset: Int

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension VersionMinCommand {
    public var version: Version {
        .init(
            major: Int((layout.version & 0xFFFF0000) >> 16),
            minor: Int((layout.version & 0x0000FF00) >> 8),
            patch: Int(layout.version & 0x000000FF)
        )
    }

    public var sdk: Version {
        .init(
            major: Int((layout.sdk & 0xFFFF0000) >> 16),
            minor: Int((layout.sdk & 0x0000FF00) >> 8),
            patch: Int(layout.sdk & 0x000000FF)
        )
    }
}
