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

#endif /* aot_cache_h */
