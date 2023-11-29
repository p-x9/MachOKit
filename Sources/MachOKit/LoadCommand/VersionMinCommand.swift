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
        .init(layout.version)
    }

    public var sdk: Version {
        .init(layout.version)
    }
}
