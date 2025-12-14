//
//  DyldChainedImportProtocol.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

public protocol DyldChainedImportProtocol: LayoutWrapper, Sendable {
    var libraryOrdinal: Int { get }
    var isWeakImport: Bool { get }
    var nameOffset: Int { get }
    var addend: Int { get }
}

extension DyldChainedImportProtocol {
    // https://opensource.apple.com/source/cctools/cctools-877.5/otool/dyld_bind_info.c.auto.html
    // `ordinalName`
    public var libraryOrdinalType: BindSpecial? {
        .init(rawValue: numericCast(libraryOrdinal))
    }
}
