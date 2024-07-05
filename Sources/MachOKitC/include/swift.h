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

// ref: https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/common/OptimizerSwift.h#L45
struct swift_optimization {
    uint32_t version;
    uint32_t padding;
    uint64_t typeConformanceHashTableCacheOffset;
    uint64_t metadataConformanceHashTableCacheOffset;
    uint64_t foreignTypeConformanceHashTableCacheOffset;
};

#endif /* swift_h */
