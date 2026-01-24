//
//  objc.h
//  
//
//  Created by p-x9 on 2024/05/29
//  
//

#ifndef objc_h
#define objc_h

#include <stdint.h>

// https://github.com/apple-oss-distributions/dyld/blob/25174f1accc4d352d9e7e6294835f9e6e9b3c7bf/common/DyldSharedCache.h#L72

struct objc_optimization
{
    uint32_t version; // = 1
    uint32_t flags;
    uint64_t headerInfoROCacheOffset;
    uint64_t headerInfoRWCacheOffset;
    uint64_t selectorHashTableCacheOffset;
    uint64_t classHashTableCacheOffset;
    uint64_t protocolHashTableCacheOffset;
    uint64_t relativeMethodSelectorBaseAddressOffset;
};

// https://github.com/apple-oss-distributions/dyld/blob/a571176e8e00c47e95b95e3156820ebec0cbd5e6/common/OptimizerObjC.h#L656
struct header_info_rw_64 {
    uint64_t isLoaded              : 1;
    uint64_t allClassesRealized    : 1;
    uint64_t next                  : 62;
};

struct header_info_rw_32 {
    uint32_t isLoaded              : 1;
    uint32_t allClassesRealized    : 1;
    uint32_t next                  : 30;
};

// https://github.com/apple-oss-distributions/dyld/blob/a571176e8e00c47e95b95e3156820ebec0cbd5e6/common/OptimizerObjC.h#L818
struct objc_headeropt_rw_t_64 {
    uint32_t count;
    uint32_t entsize;
    struct header_info_rw_64 headers[0];  // sorted by mhdr address
};

struct objc_headeropt_rw_t_32 {
    uint32_t count;
    uint32_t entsize;
    struct header_info_rw_32 headers[0];  // sorted by mhdr address
};

// https://github.com/apple-oss-distributions/dyld/blob/a571176e8e00c47e95b95e3156820ebec0cbd5e6/common/OptimizerObjC.h#L734
struct objc_header_info_ro_t_64 {
    int64_t mhdr_offset;     // offset to mach_header or mach_header_64
    int64_t info_offset;     // offset to objc_image_info *
};

struct objc_header_info_ro_t_32 {
    int32_t mhdr_offset;     // offset to mach_header or mach_header_64
    int32_t info_offset;     // offset to objc_image_info *
};

// https://github.com/apple-oss-distributions/dyld/blob/a571176e8e00c47e95b95e3156820ebec0cbd5e6/common/OptimizerObjC.h#L772
// https://github.com/apple-oss-distributions/objc4/blob/89543e2c0f67d38ca5211cea33f42c51500287d5/runtime/objc-private.h#L418
struct objc_headeropt_ro_t_64 {
    uint32_t count;
    uint32_t entsize;
    struct objc_header_info_ro_t_64 headers[0];  // sorted by mhdr address
};

struct objc_headeropt_ro_t_32 {
    uint32_t count;
    uint32_t entsize;
    struct objc_header_info_ro_t_32 headers[0];  // sorted by mhdr address
};

// https://github.com/apple-oss-distributions/dyld/blob/a571176e8e00c47e95b95e3156820ebec0cbd5e6/common/OptimizerObjC.h#L36C1-L39C3
// https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/objc-abi.h#L83

struct objc_image_info {
    int32_t version;
    uint32_t flags;
};

// https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/include/objc-shared-cache.h#L93
struct /*alignas(alignof(uint64_t)) */objc_opt_t_16 {
    uint32_t version; // = 16
    uint32_t flags;
    int32_t selopt_offset;
    int32_t headeropt_ro_offset;
    int32_t unused_clsopt_offset;
    int32_t unused_protocolopt_offset; // This is now 0 as we've moved to the new protocolopt_offset
    int32_t headeropt_rw_offset;
    int32_t unused_protocolopt2_offset;
    int32_t largeSharedCachesClassOffset;
    int32_t largeSharedCachesProtocolOffset;
    int64_t relativeMethodSelectorBaseAddressOffset; // Relative method list selectors are offsets from this address
};

// https://github.com/apple-oss-distributions/dyld/blob/bd2e880906e1e7d7863408d0bed62600a9e93686/include/objc-shared-cache.h#L655-L662
struct /*alignas(alignof(void*))*/ objc_opt_t_15 {
    uint32_t version; // = 15
    uint32_t flags;
    int32_t selopt_offset;
    int32_t headeropt_ro_offset;
    int32_t clsopt_offset;
    int32_t protocolopt_offset;
    int32_t headeropt_rw_offset;
};

// https://github.com/apple-oss-distributions/dyld/blob/5b001a7c35bf0b7cb5d58559f8a6b5b72c297401/include/objc-shared-cache.h#L645
struct /*alignas(alignof(void*))*/ objc_opt_t_13 {
    uint32_t version; // = 13
    int32_t selopt_offset;
    int32_t headeropt_offset;
    int32_t clsopt_offset;
    int32_t protocolopt_offset;
};

// https://github.com/apple-oss-distributions/dyld/blob/e4ddd0f908e098a6cf43364e2c1e4eea19af86f0/include/objc-shared-cache.h#L565-L569
struct objc_opt_t_12 {
    uint32_t version;  // = 12
    int32_t selopt_offset;
    int32_t headeropt_offset;
    int32_t clsopt_offset;
};

#endif /* objc_h */
