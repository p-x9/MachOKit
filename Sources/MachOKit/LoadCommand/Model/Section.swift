//
//  Section.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public struct Section: LayoutWrapper {
    public typealias Layout = section

    public var layout: Layout
}

extension Section {
    public var sectionName: String {
        .init(tuple: layout.sectname)
    }

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    public var flags: SectionFlags {
        .init(rawValue: layout.flags)
    }
}

public struct Section64: LayoutWrapper {
    public typealias Layout = section_64

    public var layout: Layout
}

extension Section64 {
    public var sectionName: String {
        .init(tuple: layout.sectname)
    }

    public var segmentName: String {
        .init(tuple: layout.segname)
    }

    public var flags: SectionFlags {
        .init(rawValue: layout.flags)
    }
}
