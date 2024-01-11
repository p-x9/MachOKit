//
//  DyldChainedImportProtocol.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

public protocol DyldChainedImportProtocol: LayoutWrapper {
    var libraryOrdinal: Int { get }
    var isWeakImport: Bool { get }
    var nameOffset: Int { get }
}

extension DyldChainedImportProtocol {
    public var libraryOrdinalType: LibraryOrdinalType? {
        .init(rawValue: numericCast(libraryOrdinal))
    }
}
