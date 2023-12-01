//
//  Section+Type.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public enum SectionType {
    case regular
    case zerofill
    case cstring_literals
    case _4byte_literals
    case _8byte_literals
    case literal_pointers
    case non_lazy_symbol_pointers
    case lazy_symbol_pointers
    case symbol_stubs
    case mod_init_func_pointers
    case mod_term_func_pointers
    case coalesced
    case gb_zerofill
    case interposing
    case _16byte_literals
    case dtrace_dof
    case lazy_dylib_symbol_pointers
    case thread_local_regular
    case thread_local_zerofill
    case thread_local_variables
    case thread_local_variable_pointers
    case thread_local_init_function_pointers
    case init_func_offsets
}

extension SectionType: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case S_REGULAR: self = .regular
        case S_ZEROFILL: self = .zerofill
        case S_CSTRING_LITERALS: self = .cstring_literals
        case S_4BYTE_LITERALS: self = ._4byte_literals
        case S_8BYTE_LITERALS: self = ._8byte_literals
        case S_LITERAL_POINTERS: self = .literal_pointers
        case S_NON_LAZY_SYMBOL_POINTERS: self = .non_lazy_symbol_pointers
        case S_LAZY_SYMBOL_POINTERS: self = .lazy_symbol_pointers
        case S_SYMBOL_STUBS: self = .symbol_stubs
        case S_MOD_INIT_FUNC_POINTERS: self = .mod_init_func_pointers
        case S_MOD_TERM_FUNC_POINTERS: self = .mod_term_func_pointers
        case S_COALESCED: self = .coalesced
        case S_GB_ZEROFILL: self = .gb_zerofill
        case S_INTERPOSING: self = .interposing
        case S_16BYTE_LITERALS: self = ._16byte_literals
        case S_DTRACE_DOF: self = .dtrace_dof
        case S_LAZY_DYLIB_SYMBOL_POINTERS: self = .lazy_dylib_symbol_pointers
        case S_THREAD_LOCAL_REGULAR: self = .thread_local_regular
        case S_THREAD_LOCAL_ZEROFILL: self = .thread_local_zerofill
        case S_THREAD_LOCAL_VARIABLES: self = .thread_local_variables
        case S_THREAD_LOCAL_VARIABLE_POINTERS: self = .thread_local_variable_pointers
        case S_THREAD_LOCAL_INIT_FUNCTION_POINTERS: self = .thread_local_init_function_pointers
        case S_INIT_FUNC_OFFSETS: self = .init_func_offsets
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .regular: S_REGULAR
        case .zerofill: S_ZEROFILL
        case .cstring_literals: S_CSTRING_LITERALS
        case ._4byte_literals: S_4BYTE_LITERALS
        case ._8byte_literals: S_8BYTE_LITERALS
        case .literal_pointers: S_LITERAL_POINTERS
        case .non_lazy_symbol_pointers: S_NON_LAZY_SYMBOL_POINTERS
        case .lazy_symbol_pointers: S_LAZY_SYMBOL_POINTERS
        case .symbol_stubs: S_SYMBOL_STUBS
        case .mod_init_func_pointers: S_MOD_INIT_FUNC_POINTERS
        case .mod_term_func_pointers: S_MOD_TERM_FUNC_POINTERS
        case .coalesced: S_COALESCED
        case .gb_zerofill: S_GB_ZEROFILL
        case .interposing: S_INTERPOSING
        case ._16byte_literals: S_16BYTE_LITERALS
        case .dtrace_dof: S_DTRACE_DOF
        case .lazy_dylib_symbol_pointers: S_LAZY_DYLIB_SYMBOL_POINTERS
        case .thread_local_regular: S_THREAD_LOCAL_REGULAR
        case .thread_local_zerofill: S_THREAD_LOCAL_ZEROFILL
        case .thread_local_variables: S_THREAD_LOCAL_VARIABLES
        case .thread_local_variable_pointers: S_THREAD_LOCAL_VARIABLE_POINTERS
        case .thread_local_init_function_pointers: S_THREAD_LOCAL_INIT_FUNCTION_POINTERS
        case .init_func_offsets: S_INIT_FUNC_OFFSETS
        }
    }
}

extension SectionType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .regular: "S_REGULAR"
        case .zerofill: "S_ZEROFILL"
        case .cstring_literals: "S_CSTRING_LITERALS"
        case ._4byte_literals: "S_4BYTE_LITERALS"
        case ._8byte_literals: "S_8BYTE_LITERALS"
        case .literal_pointers: "S_LITERAL_POINTERS"
        case .non_lazy_symbol_pointers: "S_NON_LAZY_SYMBOL_POINTERS"
        case .lazy_symbol_pointers: "S_LAZY_SYMBOL_POINTERS"
        case .symbol_stubs: "S_SYMBOL_STUBS"
        case .mod_init_func_pointers: "S_MOD_INIT_FUNC_POINTERS"
        case .mod_term_func_pointers: "S_MOD_TERM_FUNC_POINTERS"
        case .coalesced: "S_COALESCED"
        case .gb_zerofill: "S_GB_ZEROFILL"
        case .interposing: "S_INTERPOSING"
        case ._16byte_literals: "S_16BYTE_LITERALS"
        case .dtrace_dof: "S_DTRACE_DOF"
        case .lazy_dylib_symbol_pointers: "S_LAZY_DYLIB_SYMBOL_POINTERS"
        case .thread_local_regular: "S_THREAD_LOCAL_REGULAR"
        case .thread_local_zerofill: "S_THREAD_LOCAL_ZEROFILL"
        case .thread_local_variables: "S_THREAD_LOCAL_VARIABLES"
        case .thread_local_variable_pointers: "S_THREAD_LOCAL_VARIABLE_POINTERS"
        case .thread_local_init_function_pointers: "S_THREAD_LOCAL_INIT_FUNCTION_POINTERS"
        case .init_func_offsets: "S_INIT_FUNC_OFFSETS"
        }
    }
}
