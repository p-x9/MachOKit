//
//  chained_fixups.h
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

#ifndef chained_fixups_h
#define chained_fixups_h

// ref: https://github.com/apple-oss-distributions/xnu/blob/1031c584a5e37aff177559b9f69dbd3c8c3fd30a/EXTERNAL_HEADERS/mach-o/fixup-chains.h

#include <stdint.h>

// header of the LC_DYLD_CHAINED_FIXUPS payload
struct dyld_chained_fixups_header
{
    uint32_t    fixups_version;    // 0
    uint32_t    starts_offset;     // offset of dyld_chained_starts_in_image in chain_data
    uint32_t    imports_offset;    // offset of imports table in chain_data
    uint32_t    symbols_offset;    // offset of symbol strings in chain_data
    uint32_t    imports_count;     // number of imported symbol names
    uint32_t    imports_format;    // DYLD_CHAINED_IMPORT*
    uint32_t    symbols_format;    // 0 => uncompressed, 1 => zlib compressed
};

// This struct is embedded in LC_DYLD_CHAINED_FIXUPS payload
struct dyld_chained_starts_in_image
{
    uint32_t    seg_count;
    uint32_t    seg_info_offset[1];  // each entry is offset into this struct for that segment
    // followed by pool of dyld_chain_starts_in_segment data
};

// This struct is embedded in dyld_chain_starts_in_image
// and passed down to the kernel for page-in linking
struct dyld_chained_starts_in_segment
{
    uint32_t    size;               // size of this (amount kernel needs to copy)
    uint16_t    page_size;          // 0x1000 or 0x4000
    uint16_t    pointer_format;     // DYLD_CHAINED_PTR_*
    uint64_t    segment_offset;     // offset in memory to start of segment
    uint32_t    max_valid_pointer;  // for 32-bit OS, any value beyond this is not a pointer
    uint16_t    page_count;         // how many pages are in array
    uint16_t    page_start[1];      // each entry is offset in each page of first element in chain
    // or DYLD_CHAINED_PTR_START_NONE if no fixups on page
    // uint16_t    chain_starts[1];    // some 32-bit formats may require multiple starts per page.
    // for those, if high bit is set in page_starts[], then it
    // is index into chain_starts[] which is a list of starts
    // the last of which has the high bit set
};

// This struct is embedded in __TEXT,__chain_starts section in firmware
struct dyld_chained_starts_offsets
{
    uint32_t    pointer_format;     // DYLD_CHAINED_PTR_32_FIRMWARE
    uint32_t    starts_count;       // number of starts in array
    uint32_t    chain_starts[1];    // array chain start offsets
};

// DYLD_CHAINED_PTR_ARM64E
struct dyld_chained_ptr_arm64e_rebase
{
    uint64_t    target   : 43,
                high8    :  8,
                next     : 11,    // 4 or 8-byte stide
                bind     :  1,    // == 0
                auth     :  1;    // == 0
};

// DYLD_CHAINED_PTR_ARM64E
struct dyld_chained_ptr_arm64e_bind
{
    uint64_t    ordinal   : 16,
                zero      : 16,
                addend    : 19,    // +/-256K
                next      : 11,    // 4 or 8-byte stide
                bind      :  1,    // == 1
                auth      :  1;    // == 0
};

// DYLD_CHAINED_PTR_ARM64E
struct dyld_chained_ptr_arm64e_auth_rebase
{
    uint64_t    target    : 32,   // runtimeOffset
                diversity : 16,
                addrDiv   :  1,
                key       :  2,
                next      : 11,    // 4 or 8-byte stide
                bind      :  1,    // == 0
                auth      :  1;    // == 1
};

// DYLD_CHAINED_PTR_ARM64E
struct dyld_chained_ptr_arm64e_auth_bind
{
    uint64_t    ordinal   : 16,
                zero      : 16,
                diversity : 16,
                addrDiv   :  1,
                key       :  2,
                next      : 11,    // 4 or 8-byte stide
                bind      :  1,    // == 1
                auth      :  1;    // == 1
};

// DYLD_CHAINED_PTR_64/DYLD_CHAINED_PTR_64_OFFSET
struct dyld_chained_ptr_64_rebase
{
    uint64_t    target    : 36,    // 64GB max image size (DYLD_CHAINED_PTR_64 => vmAddr, DYLD_CHAINED_PTR_64_OFFSET => runtimeOffset)
                high8     :  8,    // top 8 bits set to this (DYLD_CHAINED_PTR_64 => after slide added, DYLD_CHAINED_PTR_64_OFFSET => before slide added)
                reserved  :  7,    // all zeros
                next      : 12,    // 4-byte stride
                bind      :  1;    // == 0
};

// DYLD_CHAINED_PTR_64
struct dyld_chained_ptr_64_bind
{
    uint64_t    ordinal   : 24,
                addend    :  8,   // 0 thru 255
                reserved  : 19,   // all zeros
                next      : 12,   // 4-byte stride
                bind      :  1;   // == 1
};

// DYLD_CHAINED_PTR_64_KERNEL_CACHE, DYLD_CHAINED_PTR_X86_64_KERNEL_CACHE
struct dyld_chained_ptr_64_kernel_cache_rebase
{
    uint64_t    target     : 30,   // basePointers[cacheLevel] + target
                cacheLevel :  2,   // what level of cache to bind to (indexes a mach_header array)
                diversity  : 16,
                addrDiv    :  1,
                key        :  2,
                next       : 12,    // 1 or 4-byte stide
                isAuth     :  1;    // 0 -> not authenticated.  1 -> authenticated
};

// DYLD_CHAINED_PTR_32
// Note: for DYLD_CHAINED_PTR_32 some non-pointer values are co-opted into the chain
// as out of range rebases.  If an entry in the chain is > max_valid_pointer, then it
// is not a pointer.  To restore the value, subtract off the bias, which is
// (64MB+max_valid_pointer)/2.
struct dyld_chained_ptr_32_rebase
{
    uint32_t    target    : 26,   // vmaddr, 64MB max image size
                next      :  5,   // 4-byte stride
                bind      :  1;   // == 0
};

// DYLD_CHAINED_PTR_32
struct dyld_chained_ptr_32_bind
{
    uint32_t    ordinal   : 20,
                addend    :  6,   // 0 thru 63
                next      :  5,   // 4-byte stride
                bind      :  1;   // == 1
};

// DYLD_CHAINED_PTR_32_CACHE
struct dyld_chained_ptr_32_cache_rebase
{
    uint32_t    target    : 30,   // 1GB max dyld cache TEXT and DATA
                next      :  2;   // 4-byte stride
};


// DYLD_CHAINED_PTR_32_FIRMWARE
struct dyld_chained_ptr_32_firmware_rebase
{
    uint32_t    target   : 26,   // 64MB max firmware TEXT and DATA
                next     :  6;   // 4-byte stride
};

// IMPORT

// DYLD_CHAINED_IMPORT
struct dyld_chained_import
{
    uint32_t    lib_ordinal :  8,
                weak_import :  1,
                name_offset : 23;
};

// DYLD_CHAINED_IMPORT_ADDEND
struct dyld_chained_import_addend
{
    uint32_t    lib_ordinal :  8,
                weak_import :  1,
                name_offset : 23;
    int32_t     addend;
};

// DYLD_CHAINED_IMPORT_ADDEND64
struct dyld_chained_import_addend64
{
    uint64_t    lib_ordinal : 16,
                weak_import :  1,
                reserved    : 15,
                name_offset : 32;
    uint64_t    addend;
};

#endif /* chained_fixups_h */
