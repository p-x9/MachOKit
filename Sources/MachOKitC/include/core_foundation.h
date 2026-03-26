//
//  core_foundation.h
//  MachOKit
//
//  Created by p-x9 on 2025/02/01
//  
//

#ifndef core_foundation_h
#define core_foundation_h

// ref: https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFRuntime.h#L222-L228
typedef struct __CFRuntimeBase64 {
    uint64_t _cfisa;
    uint8_t _cfinfo[4];
    uint32_t _rc;
} CFRuntimeBase64;

typedef struct __CFRuntimeBase32 {
    uint32_t _cfisa;
    uint8_t _cfinfo[4];
} CFRuntimeBase32;

// ref: https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFInternal.h#L332
struct CF_CONST_STRING64 {
    CFRuntimeBase64 _base;
    uint64_t _ptr;
    uint32_t _length;
};

struct CF_CONST_STRING32 {
    CFRuntimeBase32 _base;
    uint32_t _ptr;
    uint32_t _length;
};

#endif /* core_foundation_h */
