//
//  Nlist.swift
//
//
//  Created by p-x9 on 2023/12/08.
//  
//

import Foundation

public protocol NlistProtocol: LayoutWrapper, Sendable {
    /// The complete `n_value`, zero-extended for a 32-bit `nlist`.
    var rawValue: UInt64 { get }
    /// Whether any `N_STAB` bits are set, including unknown STAB codes.
    var isDebugSymbol: Bool { get }
    var flags: SymbolFlags? { get }
    var symbolDescription: SymbolDescription? { get }
    var sectionNumber: Int? { get }
}

public struct Nlist: NlistProtocol {
    public typealias Layout = nlist

    public var layout: Layout

    /// Creates a wrapper for the given C layout.
    public init(layout: Layout) {
        self.layout = layout
    }

    public var rawValue: UInt64 { UInt64(layout.n_value) }

    public var isDebugSymbol: Bool {
        Int32(layout.n_type) & N_STAB != 0
    }

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

    /// Creates a wrapper for the given C layout.
    public init(layout: Layout) {
        self.layout = layout
    }

    public var rawValue: UInt64 { layout.n_value }

    public var isDebugSymbol: Bool {
        Int32(layout.n_type) & N_STAB != 0
    }

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

extension NlistProtocol {
    /// Interprets `n_value` without converting it to a location or validating
    /// section numbers and string-table bounds.
    public var value: SymbolValue {
        guard let flags else {
            return .unknown(type: 0, value: rawValue)
        }
        let rawType = UInt8(truncatingIfNeeded: flags.rawValue)
        if isDebugSymbol {
            return .stab(type: rawType, value: rawValue)
        }
        switch flags.type {
        case .sect:
            return .sect(value: rawValue)
        case .abs:
            return .abs(value: rawValue)
        case .undf:
            if flags.contains(.ext), sectionNumber == nil, rawValue != 0 {
                return .common(size: rawValue)
            }
            return .undf(value: rawValue)
        case .pbud:
            return .pbud(value: rawValue)
        case .indr:
            return .indr(stringTableIndex: rawValue)
        case nil:
            return .unknown(type: rawType, value: rawValue)
        }
    }
}
