//
//  swift.h
//  
//
//  Created by p-x9 on 2024/07/05
//  
//

#ifndef swift_h
#define swift_h

#include <stdint.h>

// ref: https://github.com/apple-oss-distributions/dyld/blob/031f1c6ffb240a094f3f2f85f20dfd9e3f15b664/common/OptimizerSwift.h#L45
struct swift_optimization {
    uint32_t version;
    uint32_t padding;
    uint64_t typeConformanceHashTableCacheOffset;
    uint64_t metadataConformanceHashTableCacheOffset;
    uint64_t foreignTypeConformanceHashTableCacheOffset;

    uint64_t prespecializationDataCacheOffset; // added in version 2

    // limited space reserved for table offsets, they're not accessed directly
    // used for debugging only
    uint64_t prespecializedMetadataHashTableCacheOffsets[8]; // added in version 3
};

#endif /* swift_h */
