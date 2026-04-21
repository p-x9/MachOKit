import Foundation
import MachOKit

extension RebaseOpcode: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .done: "Done"
        case .set_type_imm: "Set Type (Immediate)"
        case .set_segment_and_offset_uleb: "Set Segment and Offset (ULEB)"
        case .add_addr_uleb: "Add Address (ULEB)"
        case .add_addr_imm_scaled: "Add Scaled Address (Immediate)"
        case .do_rebase_imm_times: "Rebase Immediate Times"
        case .do_rebase_uleb_times: "Rebase ULEB Times"
        case .do_rebase_add_addr_uleb: "Rebase and Add Address (ULEB)"
        case .do_rebase_uleb_times_skipping_uleb: "Rebase ULEB Times Skipping ULEB"
        }
    }
}

extension RebaseType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .pointer: "Pointer"
        case .text_absolute32: "32-bit Absolute Text"
        case .text_pcrel32: "32-bit PC-Relative Text"
        }
    }
}
