//
//  Nlist.swift
//
//
//  Created by p-x9 on 2023/12/08.
//  
//

import Foundation

public protocol NlistProtocol: LayoutWrapper {
    var flags: SymbolFlags? { get }
    var symbolDescription: SymbolDescription? { get }
    var sectionNumber: Int? { get }
}

public struct Nlist: NlistProtocol {
    public typealias Layout = nlist

    public var layout: Layout

    public var flags: SymbolFlags? {
        .init(rawValue: numericCast(layout.n_type))
    }

    public var symbolDescription: SymbolDescription? {
        .init(rawValue: numericCast(layout.n_desc))
    }

    public var sectionNumber: Int? {
        layout.n_sect == NO_SECT ? nil : numericCast(layout.n_sect)
    }
}

public struct Nlist64: NlistProtocol {
    public typealias Layout = nlist_64

    public var layout: Layout

    public var flags: SymbolFlags? {
        .init(rawValue: numericCast(layout.n_type))
    }

    public var symbolDescription: SymbolDescription? {
        .init(rawValue: numericCast(layout.n_desc))
    }

    public var sectionNumber: Int? {
        layout.n_sect == NO_SECT ? nil : numericCast(layout.n_sect)
    }
}
