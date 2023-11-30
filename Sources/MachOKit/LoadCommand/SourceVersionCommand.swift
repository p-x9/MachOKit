//
//  SourceVersionCommand.swift
//
//
//  Created by p-x9 on 2023/11/30.
//  
//

import Foundation

public struct SourceVersionCommand: LoadCommandWrapper {
    public typealias Layout = source_version_command

    public let layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension SourceVersionCommand {
    public var version: SourceVersion {
        .init(layout.version)
    }
}
