//
//  backports.h
//  MachOKit
//
//  Created by p-x9 on 2024/11/29
//  
//

#ifndef backports_h
#define backports_h

#ifdef __APPLE__

#include <mach-o/loader.h>
#include <stdint.h>

#ifndef MH_IMPLICIT_PAGEZERO
    #define MH_IMPLICIT_PAGEZERO 0x10000000
#endif

#ifndef DYLIB_USE_MARKER
    struct dylib_use_command {
        uint32_t    cmd;                     /* LC_LOAD_DYLIB or LC_LOAD_WEAK_DYLIB */
        uint32_t    cmdsize;                 /* overall size, including path */
        uint32_t    nameoff;                 /* == 28, dylibs's path offset */
        uint32_t    marker;                  /* == DYLIB_USE_MARKER */
        uint32_t    current_version;         /* dylib's current version number */
        uint32_t    compat_version;          /* dylib's compatibility version number */
        uint32_t    flags;                   /* DYLIB_USE_... flags */
    };
    #define DYLIB_USE_WEAK_LINK    0x01
    #define DYLIB_USE_REEXPORT    0x02
    #define DYLIB_USE_UPWARD    0x04
    #define DYLIB_USE_DELAYED_INIT    0x08

    #define DYLIB_USE_MARKER    0x1a741800
#endif

#ifndef PLATFORM_VISIONOS
#define PLATFORM_VISIONOS 11
#endif

#ifndef PLATFORM_VISIONOSSIMULATOR
#define PLATFORM_VISIONOSSIMULATOR 12
#endif

#ifndef LC_FUNCTION_VARIANTS
#define LC_FUNCTION_VARIANTS 0x37 /* used with linkedit_data_command */
#endif

#ifndef LC_FUNCTION_VARIANT_FIXUPS
#define LC_FUNCTION_VARIANT_FIXUPS 0x38 /* used with linkedit_data_command */
#endif

#ifndef LC_TARGET_TRIPLE
#define LC_TARGET_TRIPLE 0x39 /* target triple used to compile */

/*
 * The target_triple_command contains a string which specifies the
 * target triple (e.g. "arm64e-apple-macosx15.0.0") used to compile the code.
 */
struct target_triple_command {
    uint32_t     cmd;        /* LC_TARGET_TRIPLE */
    uint32_t     cmdsize;    /* including string */
    union lc_str triple;    /* target triple string */
};
#endif

/*
 * arm64e.x1 -- the checked-pointer-arithmetic slice (Arm FEAT_CPA2), new in the
 * macOS 27 / iOS 27 SDKs. Every macOS 27 dyld shared cache is built for it.
 */
#ifndef CPU_SUBTYPE_ARM64_X1
    /* The non-e x1 is defined in other tooling, but it's otherwise unused. */
    #define CPU_SUBTYPE_ARM64_X1 ((cpu_subtype_t) 3)
#endif

#ifndef CPU_SUBTYPE_ARM64E_X1
    #define CPU_SUBTYPE_ARM64E_X1 ((cpu_subtype_t) 12)
#endif

#ifndef PLATFORM_MACOS_EXCLAVECORE
#define PLATFORM_MACOS_EXCLAVECORE 15
#define PLATFORM_MACOS_EXCLAVEKIT 16
#define PLATFORM_IOS_EXCLAVECORE 17
#define PLATFORM_IOS_EXCLAVEKIT 18
#define PLATFORM_TVOS_EXCLAVECORE 19
#define PLATFORM_TVOS_EXCLAVEKIT 20
#define PLATFORM_WATCHOS_EXCLAVECORE 21
#define PLATFORM_WATCHOS_EXCLAVEKIT 22
#define PLATFORM_VISIONOS_EXCLAVECORE 23
#define PLATFORM_VISIONOS_EXCLAVEKIT 24
#endif

#endif /* __APPLE__ */

#ifndef EXPORT_SYMBOL_FLAGS_FUNCTION_VARIANT
#define EXPORT_SYMBOL_FLAGS_FUNCTION_VARIANT  0x20
#endif

#endif /* backports_h */
