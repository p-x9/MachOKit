//
//  backports.h
//  MachOKit
//
//  Created by p-x9 on 2024/11/29
//  
//

#ifndef backports_h
#define backports_h

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


#endif /* backports_h */
