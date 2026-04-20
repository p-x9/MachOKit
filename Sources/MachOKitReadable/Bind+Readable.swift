import Foundation
import MachOKit

extension BindOpcode: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .done: "Done"
        case .set_dylib_ordinal_imm: "Set Dylib Ordinal (Immediate)"
        case .set_dylib_ordinal_uleb: "Set Dylib Ordinal (ULEB)"
        case .set_dylib_special_imm: "Set Special Dylib (Immediate)"
        case .set_symbol_trailing_flags_imm: "Set Symbol with Trailing Flags (Immediate)"
        case .set_type_imm: "Set Type (Immediate)"
        case .set_addend_sleb: "Set Addend (SLEB)"
        case .set_segment_and_offset_uleb: "Set Segment and Offset (ULEB)"
        case .add_addr_uleb: "Add Address (ULEB)"
        case .do_bind: "Bind"
        case .do_bind_add_addr_uleb: "Bind and Add Address (ULEB)"
        case .do_bind_add_addr_imm_scaled: "Bind and Add Scaled Address (Immediate)"
        case .do_bind_uleb_times_skipping_uleb: "Bind ULEB Times Skipping ULEB"
        case .threaded: "Threaded"
        }
    }
}

extension BindSubOpcode: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .threaded_set_bind_ordinal_table_size_uleb: "Threaded: Set Bind Ordinal Table Size (ULEB)"
        case .threaded_apply: "Threaded: Apply"
        }
    }
}

extension BindSpecial: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .dylib_self: "Self Dylib"
        case .dylib_main_executable: "Main Executable"
        case .dylib_flat_lookup: "Flat Namespace Lookup"
        case .dylib_weak_lookup: "Weak Lookup"
        }
    }
}

extension BindType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .pointer: "Pointer"
        case .text_absolute32: "32-bit Absolute Text"
        case .text_pcrel32: "32-bit PC-Relative Text"
        }
    }
}

extension BindOperationsKind: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .normal: "Normal"
        case .weak: "Weak"
        case .lazy: "Lazy"
        }
    }
}
