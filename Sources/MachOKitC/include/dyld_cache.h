//
//  dyld_cache.h
//
//
//  Created by p-x9 on 2024/10/09
//
//

#ifndef dyld_cache_h
#define dyld_cache_h

#ifndef __linux__

#include <stddef.h>
#include <mach-o/loader.h>

extern const void* _dyld_get_shared_cache_range(size_t* length);
extern const struct mach_header* dyld_image_header_containing_address(const void* addr);
extern const char* dyld_shared_cache_file_path(void);

#endif

#endif /* dyld_cache_h */
