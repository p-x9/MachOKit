import Foundation
import MachOKit

extension SectionType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .regular: "Regular"
        case .zerofill: "Zero Fill"
        case .cstring_literals: "C String Literals"
        case ._4byte_literals: "4-byte Literals"
        case ._8byte_literals: "8-byte Literals"
        case .literal_pointers: "Literal Pointers"
        case .non_lazy_symbol_pointers: "Non-Lazy Symbol Pointers"
        case .lazy_symbol_pointers: "Lazy Symbol Pointers"
        case .symbol_stubs: "Symbol Stubs"
        case .mod_init_func_pointers: "Module Initializer Pointers"
        case .mod_term_func_pointers: "Module Terminator Pointers"
        case .coalesced: "Coalesced"
        case .gb_zerofill: "Giant Zero Fill"
        case .interposing: "Interposing"
        case ._16byte_literals: "16-byte Literals"
        case .dtrace_dof: "DTrace Object Format"
        case .lazy_dylib_symbol_pointers: "Lazy Dylib Symbol Pointers"
        case .thread_local_regular: "Thread-Local Regular"
        case .thread_local_zerofill: "Thread-Local Zero Fill"
        case .thread_local_variables: "Thread-Local Variables"
        case .thread_local_variable_pointers: "Thread-Local Variable Pointers"
        case .thread_local_init_function_pointers: "Thread-Local Initializer Pointers"
        case .init_func_offsets: "Initializer Function Offsets"
        }
    }
}

extension SectionAttributes.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .pure_instructions: "Pure Instructions"
        case .no_toc: "No Table of Contents"
        case .strip_static_syms: "Strip Static Symbols"
        case .no_dead_strip: "No Dead Stripping"
        case .live_support: "Live Support"
        case .self_modifying_code: "Self-Modifying Code"
        case .debug: "Debug"
        case .some_instructions: "Some Instructions"
        case .ext_reloc: "External Relocations"
        case .loc_reloc: "Local Relocations"
        }
    }
}

extension SectionAttributes {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension SectionAttributes: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}
