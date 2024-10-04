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
    uint32_t version;
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

#endif /* objc_h */
