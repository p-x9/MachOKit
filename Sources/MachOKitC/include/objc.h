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

#endif /* objc_h */
