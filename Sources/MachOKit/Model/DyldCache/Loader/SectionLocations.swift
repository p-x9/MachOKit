//
//  SectionLocations.swift
//  MachOKit
//
//  Created by p-x9 on 2024/11/16
//  
//

import Foundation

public struct SectionLocations: LayoutWrapper, Sendable {
    public typealias Layout = section_locations

    public var layout: Layout
}

extension SectionLocations {
    // [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/include/mach-o/dyld_priv.h#L62)
    public enum SectionKind: Int, Sendable, CaseIterable {
        // TEXT:
        case text_swift5_protos
        case text_swift5_proto
        case text_swift5_types
        case text_swift5_replace
        case text_swift5_replace2
        case text_swift5_ac_funcs

        // DATA*:
        case objc_image_info
        case data_sel_refs
        case data_msg_refs
        case data_class_refs
        case data_super_refs
        case data_protocol_refs
        case data_class_list
        case data_non_lazy_class_list
        case data_stub_list
        case data_category_list
        case data_category_list2
        case data_non_lazy_category_list
        case data_protocol_list
        case data_objc_fork_ok
        case data_raw_isa

        // ~~ version 1 ~~
    }
}

extension SectionLocations {
    public struct Section: Sendable {
        public let offset: Int
        public let size: Int
        public let kind: SectionKind
    }
}

extension SectionLocations {
    public func section(for kind: SectionKind) -> Section {
        var offsets = layout.offsets
        var sizes = layout.sizes
        let offset = withUnsafePointer(to: &offsets) {
            UnsafeRawPointer($0)
                .assumingMemoryBound(to: UInt64.self)
                .advanced(by: kind.rawValue).pointee
        }
        let size = withUnsafePointer(to: &sizes) {
            UnsafeRawPointer($0)
                .assumingMemoryBound(to: UInt64.self)
                .advanced(by: kind.rawValue).pointee
        }
        return .init(
            offset: numericCast(offset),
            size: numericCast(size),
            kind: kind
        )
    }
}
