//
//  Section+Flags.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public struct SectionFlags {
    public let rawValue: UInt32

    public var type: SectionType? {
        let rawValue = rawValue & UInt32(SECTION_TYPE)
        return .init(rawValue: Int32(rawValue))
    }

    public var attributes: SectionAttributes {
        .init(rawValue: rawValue & SECTION_ATTRIBUTES)
    }
}
