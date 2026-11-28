/// The interpretation of a symbol's `n_value`, without resolving its location.
public enum SymbolValue: Sendable, Equatable {
    /// N_SECT — defined in a section; location interpretation needs Mach-O context.
    case sect(value: UInt64)
    /// N_ABS — an absolute value that is not relocated.
    case abs(value: UInt64)
    /// N_UNDF — undefined; preserves the original value for unusual inputs too.
    case undf(value: UInt64)
    /// N_UNDF | N_EXT, NO_SECT, nonzero n_value — the common symbol's byte size.
    case common(size: UInt64)
    /// N_PBUD — prebound undefined.
    case pbud(value: UInt64)
    /// N_INDR — the target symbol name's index in the string table.
    case indr(stringTableIndex: UInt64)
    /// N_STAB — an uninterpreted debug value and the complete n_type byte.
    case stab(type: UInt8, value: UInt64)
    /// Unrecognized N_TYPE — preserves the complete n_type byte and n_value.
    case unknown(type: UInt8, value: UInt64)
}
