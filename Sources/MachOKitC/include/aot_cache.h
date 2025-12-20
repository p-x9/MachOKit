//
//  aot_cache.h
//  MachOKit
//
//  Created by p-x9 on 2025/01/29
//  
//

#ifndef aot_cache_h
#define aot_cache_h

#include <stdint.h>

// ref: /Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/kern/debug.h
#define CAMBRIA_VERSION_INFO_SIZE 32
struct aot_cache_header {
    char     magic[8];
    uint8_t  uuid[16];
    uint8_t  x86_uuid[16];
    uint8_t  cambria_version[CAMBRIA_VERSION_INFO_SIZE];
    uint64_t code_signature_offset;
    uint64_t code_signature_size;
    uint32_t num_code_fragments;
    uint32_t header_size;
    // shared_file_mapping_np mappings is omitted here
};

#define LC_AOT_METADATA 0xcacaca01

struct aot_metadata_command {
    uint32_t cmd;         // LC_AOT_METADATA
    uint32_t cmdsize;     // = 0x20

    // offset from linkedit segment starts
    uint32_t x86_image_path_offset;
    uint32_t x86_image_path_size;

    uint32_t fragment_offset;
    uint32_t fragment_count; // == 1

    // address of __TEXT,__text section starts (x86_64)
    uint32_t x86_code_address;
    uint32_t _field8;
};

// ref: https://github.com/FFRI/ProjectChampollion/blob/b2c083206e3dde48c00d72be181483428463686c/AotSharedCacheExtractor/main.py#L100
// decompile `/usr/libexec/rosetta/runtime` (macOS 15.7（24G222）)
struct aot_cache_code_fragment_metadata {
    uint32_t type;

    // cache
    int32_t image_path_offset;

    // (cache(x86).headerStartOffsetInCache + headerSize + header.sizeofcmds) -> align up with 64
    int32_t x86_code_offset;
    int32_t x86_code_size;

    int32_t arm_code_offset;
    int32_t arm_code_size;

    // offset from fragments starts
    int32_t branch_data_offset;
    int32_t branch_data_size;

    // offset from fragments starts
    int32_t instruction_map_offset;
    int32_t instruction_map_size;
};

struct aot_code_fragment_metadata {
    int32_t x86_code_offset;
    int32_t x86_code_size;

    int32_t arm_code_offset;
    int32_t arm_code_size;

    // offset from linkedit segment starts
    int32_t branch_data_offset;
    int32_t branch_data_size;

    // offset from linkedit segment starts
    int32_t instruction_map_offset;
    int32_t instruction_map_size;
};

struct aot_instruction_map_header {
    uint32_t _field1; // 66052 fixed?
    uint32_t _field2; // reserved?
    uint32_t _field3; // reserved?
    uint32_t _field4; // reserved?
    uint32_t map_size;
    uint32_t entry_count;
    uint32_t index_offset;
    // sizeof(first_submap_offset) * entry_count + index_offset
    uint32_t first_submap_offset;
};

struct aot_instruction_map_index_entry {
    /// offset from `aot_code_fragment_metadata->x86_code_offset`
    uint32_t x86_code_offset;
    /// offset from `aot_code_fragment_metadata->arm_code_offset`
    uint32_t arm_code_offset;
    /// offset from `aot_instruction_map_header->first_submap_offset`
    uint32_t submap_offset;
    uint32_t flags; // ?
};

#pragma pack(push, 1)

struct aot_branch_data_header {
    uint32_t kind;
    uint32_t _field2;
    uint32_t data_size;
    uint32_t entry_count;
};

struct aot_branch_data_index_entry {
    uint16_t index;
    uint16_t _field2;
    uint8_t _field3;
    uint32_t _field4;
};

struct aot_branch_data_index_entry_compact {
    uint8_t index;
    uint8_t _field2;
    uint8_t _field3;
    uint16_t _field4;
};

struct aot_branch_data_index_entry_extended {
    uint16_t index;
    uint16_t _field2;
    uint16_t _field3;
    uint8_t _field4;
    uint16_t _field5;
    uint8_t _field6;
};

#pragma pack(pop)

#endif /* aot_cache_h */
