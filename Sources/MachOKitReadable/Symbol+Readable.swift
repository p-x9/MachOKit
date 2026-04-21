import Foundation
import MachOKit

extension SymbolType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .undf: "Undefined"
        case .abs: "Absolute"
        case .sect: "Defined in Section"
        case .pbud: "Prebound Undefined"
        case .indr: "Indirect"
        }
    }
}

extension SymbolReferenceFlag: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .undefined_non_lazy: "Undefined Non-Lazy"
        case .undefined_lazy: "Undefined Lazy"
        case .defined: "Defined"
        case .private_defined: "Private Defined"
        case .private_undefined_non_lazy: "Private Undefined Non-Lazy"
        case .private_undefined_lazy: "Private Undefined Lazy"
        }
    }
}

extension SymbolLibraryOrdinalType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .self: "Self Library"
        case .dynamic_lookup_ordinal: "Dynamic Lookup"
        case .executable_ordinal: "Main Executable"
        }
    }
}

extension SymbolFlags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .pext: "Private External"
        case .ext: "External"
        }
    }
}

extension SymbolFlags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension SymbolFlags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}

extension SymbolDescription.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .referenced_dynamically: "Referenced Dynamically"
        case .no_dead_strip: "No Dead Strip"
        case .desc_discarded: "Description Discarded"
        case .weak_ref: "Weak Reference"
        case .weak_def: "Weak Definition"
        case .ref_to_weak: "Reference to Weak"
        case .arm_thumb_def: "ARM Thumb Definition"
        case .symbol_resolver: "Symbol Resolver"
        case .alt_entry: "Alternate Entry"
        case .cold_func: "Cold Function"
        }
    }
}

extension SymbolDescription {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension SymbolDescription: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}

extension Stab: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .gsym: "Global Symbol"
        case .fname: "Procedure Name (F77 Kludge)"
        case .fun: "Procedure Name"
        case .stsym: "Data Segment File-Scope Variable"
        case .lcsym: "BSS Segment File-Scope Variable"
        case .bnsym: "Begin Nsect Symbol"
        case .ast: "AST File Path"
        case .opt: "GCC2 Compiled"
        case .rsym: "Register Symbol"
        case .sline: "Source Line"
        case .ensym: "End Nsect Symbol"
        case .ssym: "Structure Element"
        case .so: "Source File Name"
        case .oso: "Object File Name"
        case .lsym: "Local Symbol"
        case .bincl: "Include File Begin"
        case .sol: "Included Source File Name"
        case .params: "Compiler Parameters"
        case .version: "Compiler Version"
        case .olevel: "Compiler Optimization Level"
        case .psym: "Parameter"
        case .eincl: "Include File End"
        case .entry: "Alternate Entry"
        case .lbrac: "Left Bracket"
        case .excl: "Deleted Include File"
        case .rbrac: "Right Bracket"
        case .bcomm: "Begin Common"
        case .ecomm: "End Common"
        case .ecoml: "End Common (Local Name)"
        case .leng: "Second Stab Entry with Length"
        case .pc: "Global Pascal Symbol"
        }
    }
}
