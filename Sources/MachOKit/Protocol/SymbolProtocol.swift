//
//  Symbol.swift
//
//
//  Created by p-x9 on 2023/12/14.
//  
//

import Foundation

public protocol SymbolProtocol {
    var name: String { get }

    /// Offset from start of mach header (`MachO`)
    /// File offset from mach header (`MachOFile`)
    ///
    /// Legacy host-sized representation. Values exceeding the host's integer
    /// width are truncated; image offsets also include a wrapping base adjustment.
    /// Use `rawValue` or `value` to read the complete symbol value.
    var offset: Int { get }

    /// Nlist or Nlist64
    var nlist: any NlistProtocol { get }
}

extension SymbolProtocol {
    /// The complete `n_value`, without a base adjustment or host-width truncation.
    public var rawValue: UInt64 { nlist.rawValue }

    /// Whether any `N_STAB` bits are set, including unknown STAB codes.
    public var isDebugSymbol: Bool { nlist.isDebugSymbol }

    /// Interprets `n_value` without resolving a file or runtime location.
    public var value: SymbolValue { nlist.value }

    public var demangledName: String {
        stdlib_demangleName(name) ?? cxa_demangle(name) ?? name
    }
}
