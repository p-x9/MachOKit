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
    uint32_t version; // = 1-2
    uint32_t flags;
    uint64_t headerInfoROCacheOffset;
    uint64_t headerInfoRWCacheOffset;
    uint64_t selectorHashTableCacheOffset;
    uint64_t classHashTableCacheOffset;
    uint64_t protocolHashTableCacheOffset;
    uint64_t relativeMethodSelectorBaseAddressOffset;

    // Added in version 2
    uint64_t relativeMethodSelectorBufferSize;
    uint64_t relativeMethodTypesBufferSize; // this buffer starts at the end of the selectors buffer
};

// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/OptimizerObjC.h#L45-L227
// Precomputed perfect hash table of strings.
// Base class for precomputed selector, class and protocol tables.
struct objc_string_hash_table {
    uint32_t version;
    uint32_t capacity;
    uint32_t occupied;
    uint32_t shift;
    uint32_t mask;
    uint64_t salt;

    uint32_t scramble[256];
    uint8_t tab[0];                    /* tab[mask+1] (always power-of-2) */
    // uint8_t checkbytes[capacity];   /* check byte for each string */
    // int32_t offsets[capacity];      /* offsets from &capacity to cstrings */
};

// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/OptimizerObjC.h#L275-L314
// ObjectHashTable (ClassHashTable / ProtocolHashTable) continues after objc_string_hash_table:
//   ObjectData objectOffsets[capacity];
//   uint32_t duplicateCount;
//   ObjectData duplicateOffsets[duplicatedClasses];
struct objc_object_hash_table_object {
    uint64_t isDuplicate       : 1;  // == 0
    uint64_t objectCacheOffset : 47; // Offset from the shared cache base to the Class/Protocol
    uint64_t dylibObjCIndex    : 16; // Index in to the HeaderInfoRW dylibs for this Class/Protocol
};

struct objc_object_hash_table_duplicate {
    uint64_t isDuplicate : 1;  // == 1
    uint64_t index       : 47;
    uint64_t count       : 16;
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

    // Added in the middle of version 15 without bumping the version (dyld-732 / objc4-779).
    // Upstream renamed `protocolopt_offset` to `unused_protocolopt_offset` (always 0 since then)
    // and appended this field as `protocolopt_offset`, pointing to `objc_protocolopt2_t`.
    // It is named `protocolopt2_offset` here, matching `unused_protocolopt2_offset` in version 16.
    // In earlier version 15 caches this is the zero-filled padding of the pointer-aligned header.
    // https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L753-L796
    // https://github.com/apple-oss-distributions/dyld/blob/84bd745c32faa3a7cb1b15d1516aa695377841df/dyld3/shared-cache/OptimizerObjC.cpp#L974-L977
    // https://github.com/apple-oss-distributions/dyld/blob/4b6558a50e2ec117273396599cee84317da12375/dyld3/shared-cache/OptimizerObjC.cpp#L504
    // https://github.com/apple-oss-distributions/objc4/blob/289296d8da04b033c0f254e66faf81d486953d16/runtime/objc-sel-table.s#L13-L21
    int32_t protocolopt2_offset;
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

// Precomputed perfect hash table of strings used by objc_opt_t version 12 - 15.
// Base of objc_selopt_t, objc_clsopt_t, objc_protocolopt_t and objc_protocolopt2_t.
// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L173-L185
// In version 12, `unused1` was named `zero`, and empty buckets point to it instead of having offset 0.
// https://github.com/apple-oss-distributions/dyld/blob/7190f7fddb784e916f2a144fa520e54949ed5c2f/include/objc-shared-cache.h#L159-L171
// https://github.com/apple-oss-distributions/dyld/blob/7190f7fddb784e916f2a144fa520e54949ed5c2f/include/objc-shared-cache.h#L226
struct __attribute__((packed)) objc_stringhash_t {
    uint32_t capacity;
    uint32_t occupied;
    uint32_t shift;
    uint32_t mask;
    uint32_t unused1;  // was zero
    uint32_t unused2;  // alignment pad
    uint64_t salt;

    uint32_t scramble[256];
    uint8_t tab[0];                   /* tab[mask+1] (always power-of-2) */
    // uint8_t checkbytes[capacity];  /* check byte for each string */
    // int32_t offsets[capacity];     /* offsets from &capacity to cstrings */
};

// objc_clsopt_t and objc_protocolopt2_t continue after objc_stringhash_t:
//   objc_classheader_t classOffsets[capacity]; /* offsets from &capacity to class_t and header_info */
//   uint32_t duplicateCount;
//   objc_classheader_t duplicateOffsets[duplicatedClasses];
// objc_protocolopt_t continues after objc_stringhash_t:
//   int32_t protocolOffsets[capacity]; /* offsets from &capacity to protocol_t */
// https://github.com/apple-oss-distributions/dyld/blob/3f24a36068a96722cf3acbd5087983ce658e9d70/include/objc-shared-cache.h#L378-L388
struct objc_classheader_t {
    int32_t clsOffset;
    int32_t hiOffset;

    // For duplicate class names:
    // clsOffset = count<<1 | 1
    // duplicated classes are duplicateOffsets[hiOffset..hiOffset+count-1]
};

#endif /* objc_h */
