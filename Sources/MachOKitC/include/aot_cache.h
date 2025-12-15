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

// ref: https://github.com/FFRI/ProjectChampollion/blob/b2c083206e3dde48c00d72be181483428463686c/AotSharedCacheExtractor/main.py#L100
// decompile `/usr/libexec/rosetta/runtime` (macOS 15.7（24G222）)
struct aot_code_fragment_metadata {
    uint32_t type;

    // cache
    int32_t image_path_offset;

    // (cache(x86).headerStartOffsetInCache + headerSize + header.sizeofcmds) -> align up with 64
    int32_t x86_code_offset;
    int32_t x86_code_size;

    int32_t arm_code_offset;
    int32_t arm_code_size;

    int32_t branch_map_offset;
    int32_t branch_map_size;

    int32_t instruction_map_offset;
    int32_t instruction_map_size;
};


#endif /* aot_cache_h */
