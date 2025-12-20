//
//  LoadCommandWrapper.swift
//  
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public protocol LoadCommandWrapper: LayoutWrapper, Sendable {
    var offset: Int { get }

    mutating func swap()
}

extension LoadCommandWrapper {
    // swiftlint:disable:next unavailable_function
    public func swap() {
        fatalError("Not Implemented")
    }
}

extension LoadCommandWrapper where Layout == segment_command {
    public mutating func swap() {
        swap_segment_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == symtab_command {
    public mutating func swap() {
        swap_symtab_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == symseg_command {
    public mutating func swap() {
        swap_symseg_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == thread_command {
    public mutating func swap() {
        swap_thread_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == fvmlib_command {
    public mutating func swap() {
        swap_fvmlib_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == ident_command {
    public mutating func swap() {
        swap_ident_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == fvmfile_command {
    public mutating func swap() {
        swap_fvmfile_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == load_command {
    public mutating func swap() {
        swap_load_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == dysymtab_command {
    public mutating func swap() {
        swap_dysymtab_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == dylib_command {
    public mutating func swap() {
        swap_dylib_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == dylinker_command {
    public mutating func swap() {
        swap_dylinker_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == prebound_dylib_command {
    public mutating func swap() {
        swap_prebound_dylib_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == routines_command {
    public mutating func swap() {
        swap_routines_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == sub_framework_command {
    public mutating func swap() {
        swap_sub_framework_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == sub_umbrella_command {
    public mutating func swap() {
        swap_sub_umbrella_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == sub_client_command {
    public mutating func swap() {
        swap_sub_client_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == sub_library_command {
    public mutating func swap() {
        swap_sub_library_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == twolevel_hints_command {
    public mutating func swap() {
        swap_twolevel_hints_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == prebind_cksum_command {
    public mutating func swap() {
        swap_prebind_cksum_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == segment_command_64 {
    public mutating func swap() {
        swap_segment_command_64(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == routines_command_64 {
    public mutating func swap() {
        swap_routines_command_64(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == uuid_command {
    public mutating func swap() {
        swap_uuid_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == rpath_command {
    public mutating func swap() {
        swap_rpath_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == linkedit_data_command {
    public mutating func swap() {
        swap_linkedit_data_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == encryption_info_command {
    public mutating func swap() {
        swap_encryption_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == dyld_info_command {
    public mutating func swap() {
        swap_dyld_info_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == version_min_command {
    public mutating func swap() {
        swap_version_min_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == entry_point_command {
    public mutating func swap() {
        swap_entry_point_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == source_version_command {
    public mutating func swap() {
        swap_source_version_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == encryption_info_command_64 {
    public mutating func swap() {
        swap_encryption_command_64(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == linker_option_command {
    public mutating func swap() {
        swap_linker_option_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == note_command {
    public mutating func swap() {
        swap_note_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == build_version_command {
    public mutating func swap() {
        swap_build_version_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == fileset_entry_command {
    public mutating func swap() {
        swap_fileset_entry_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == target_triple_command {
    public mutating func swap() {
        swap_target_triple_command(&layout, NXHostByteOrder())
    }
}

extension LoadCommandWrapper where Layout == aot_metadata_command {
    public mutating func swap() {
        swap_aot_metadata_command(&layout, NXHostByteOrder())
    }
}

public func swap_target_triple_command(
    _ dl: UnsafeMutablePointer<target_triple_command>!,
    _ target_byte_sex: NXByteOrder
) {
    dl.pointee.cmd = dl.pointee.cmd.byteSwapped
    dl.pointee.cmdsize = dl.pointee.cmdsize.byteSwapped
    dl.pointee.triple.offset = dl.pointee.triple.offset.byteSwapped
}

public func swap_aot_metadata_command(
    _ dl: UnsafeMutablePointer<aot_metadata_command>!,
    _ target_byte_sex: NXByteOrder
) {
    dl.pointee.cmd = dl.pointee.cmd.byteSwapped
    dl.pointee.cmdsize = dl.pointee.cmdsize.byteSwapped

    dl.pointee.x86_image_path_offset = dl.pointee.x86_image_path_offset.byteSwapped
    dl.pointee.x86_image_path_size = dl.pointee.x86_image_path_size.byteSwapped

    dl.pointee.fragment_offset = dl.pointee.fragment_offset.byteSwapped
    dl.pointee.fragment_count = dl.pointee.fragment_count.byteSwapped

    dl.pointee.x86_code_address = dl.pointee.x86_code_address.byteSwapped
    dl.pointee._field8 = dl.pointee._field8.byteSwapped
}
