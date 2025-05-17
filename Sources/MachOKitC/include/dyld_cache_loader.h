//
//  dyld_cache_loader.h
//
//
//  Created by p-x9 on 2024/07/09
//
//

#ifndef dyld_cache_loader_h
#define dyld_cache_loader_h

#include <stdint.h>
#include <stdbool.h>
//#include <uuid/uuid.h>
typedef uint8_t uuid_t[16];
// https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/dyld/PrebuiltLoader.h#L254
struct prebuilt_loader_set {
    uint32_t    magic;
    uint32_t    versionHash;   // PREBUILTLOADER_VERSION
    uint32_t    length;
    uint32_t    loadersArrayCount;
    uint32_t    loadersArrayOffset;
    uint32_t    cachePatchCount;
    uint32_t    cachePatchOffset;
    uint32_t    dyldCacheUUIDOffset;
    uint32_t    mustBeMissingPathsCount;
    uint32_t    mustBeMissingPathsOffset;
    // ObjC prebuilt data
    uint32_t    objcSelectorHashTableOffset;
    uint32_t    objcClassHashTableOffset;
    uint32_t    objcProtocolHashTableOffset;
    uint32_t    objcFlags; // (from dyld-1284.13) (reserved)
    uint64_t    objcProtocolClassCacheOffset;

    // Swift prebuilt data (from dyld-1160.6)
    uint32_t    swiftTypeConformanceTableOffset;
    uint32_t    swiftMetadataConformanceTableOffset;
    uint32_t    swiftForeignTypeConformanceTableOffset;

    // (from dyld-1284.13)
    uint32_t    padding1;
};

struct loader_ref {
    uint16_t    index       : 15,   // index into PrebuiltLoaderSet
                app         :  1;   // app vs dyld cache PrebuiltLoaderSet
};

struct code_signature_in_file
{
    uint32_t   fileOffset;
    uint32_t   size;
};

// https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/dyld/Loader.h#L71
// https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/include/mach-o/dyld_priv.h#L89
struct section_locations {
    uint32_t version;
    uint32_t flags;

    uint64_t offsets[21 /* _dyld_section_location_count */];
    uint64_t sizes[21];
};

struct loader_pre1165_3 {
    const uint32_t      magic;                    // kMagic
    const uint16_t      isPrebuilt         :  1,  // PrebuiltLoader vs JustInTimeLoader
                        dylibInDyldCache   :  1,
                        hasObjC            :  1,
                        mayHavePlusLoad    :  1,
                        hasReadOnlyData    :  1,  // __DATA_CONST
                        neverUnload        :  1,  // part of launch or has non-unloadable data (e.g. objc, tlv)
                        leaveMapped        :  1,  // RTLD_NODELETE
                        hasReadOnlyObjC    :  1,  // Has __DATA_CONST,__objc_selrefs section // from 1042.1
                        pre2022Binary      :  1,
                        isPremapped        :  1,  // mapped by exclave core // from dyld-1122.1
                        padding            :  6;
    struct loader_ref   ref;
};

struct loader {
    const uint32_t      magic;                    // kMagic
    const uint16_t      isPrebuilt         :  1,  // PrebuiltLoader vs JustInTimeLoader
                        dylibInDyldCache   :  1,
                        hasObjC            :  1,
                        mayHavePlusLoad    :  1,
                        hasReadOnlyData    :  1,  // __DATA_CONST.  Don't use directly.  Use hasConstantSegmentsToProtect()
                        neverUnload        :  1,  // part of launch or has non-unloadable data (e.g. objc, tlv)
                        leaveMapped        :  1,  // RTLD_NODELETE
                        hasReadOnlyObjC    :  1,  // Has __DATA_CONST,__objc_selrefs section
                        pre2022Binary      :  1,
                        isPremapped        :  1,  // mapped by exclave core
                        hasUUIDLoadCommand :  1,
                        hasWeakDefs        :  1,
                        hasTLVs            :  1,
                        belowLibSystem     :  1,
                        padding            :  2;
    struct loader_ref   ref;
    uuid_t              uuid;
    uint32_t            cpusubtype;
    uint32_t            unused;
};

struct prebuilt_loader_pre1165_3 {
    struct loader_pre1165_3   loader;

    uint16_t            pathOffset;
    uint16_t            dependentLoaderRefsArrayOffset; // offset to array of LoaderRef
    uint16_t            dependentKindArrayOffset;       // zero if all deps normal
    uint16_t            fixupsLoadCommandOffset;

    uint16_t            altPathOffset;                  // if install_name does not match real path
    uint16_t            fileValidationOffset;           // zero or offset to FileValidationInfo

    uint16_t            hasInitializers  :  1,
                        isOverridable    :  1,          // if in dyld cache, can roots override it
                        supportsCatalyst :  1,          // if false, this cannot be used in catalyst process
                        overridesCache   :  1,          // catalyst side of unzippered twin
                        regionsCount     : 12;
    uint16_t            regionsOffset;                  // offset to Region array

    uint16_t            depCount;
    uint16_t            bindTargetRefsOffset;
    uint32_t            bindTargetRefsCount;            // bind targets can be large, so it is last
    // After this point, all offsets in to the PrebuiltLoader need to be 32-bits as the bind targets can be large

    uint32_t            objcBinaryInfoOffset;           // zero or offset to ObjCBinaryInfo
    uint16_t            indexOfTwin;                    // if in dyld cache and part of unzippered twin, then index of the other twin
    uint16_t            reserved1;

    uint64_t            exportsTrieLoaderOffset;
    uint32_t            exportsTrieLoaderSize;
    uint32_t            vmSpace;

    struct code_signature_in_file codeSignature;

    uint32_t            patchTableOffset;

    uint32_t            overrideBindTargetRefsOffset;
    uint32_t            overrideBindTargetRefsCount;

    struct section_locations    sectionLocations; // from dyld-1160.6
};

// ref: https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/dyld/PrebuiltLoader.h#L83
struct prebuilt_loader {
    struct loader       loader;

    // Main
    uint16_t            pathOffset;
    uint16_t            dependentLoaderRefsArrayOffset; // offset to array of LoaderRef
    uint16_t            dependentKindArrayOffset;       // zero if all deps normal
    uint16_t            fixupsLoadCommandOffset;

    uint16_t            altPathOffset;                  // if install_name does not match real path
    uint16_t            fileValidationOffset;           // zero or offset to FileValidationInfo

    uint16_t            hasInitializers      :  1,
                        isOverridable        :  1,      // if in dyld cache, can roots override it
                        supportsCatalyst     :  1,      // if false, this cannot be used in catalyst process
                        isCatalystOverride   :  1,      // catalyst side of unzippered twin
                        regionsCount         : 12;
    uint16_t            regionsOffset;                  // offset to Region array

    uint16_t            depCount;
    uint16_t            bindTargetRefsOffset;
    uint32_t            bindTargetRefsCount;            // bind targets can be large, so it is last
    // After this point, all offsets in to the PrebuiltLoader need to be 32-bits as the bind targets can be large

    uint32_t            objcBinaryInfoOffset;           // zero or offset to ObjCBinaryInfo
    uint16_t            indexOfTwin;                    // if in dyld cache and part of unzippered twin, then index of the other twin
    uint16_t            reserved1;

    uint64_t            exportsTrieLoaderOffset;
    uint32_t            exportsTrieLoaderSize;
    uint32_t            vmSpace;

    struct code_signature_in_file codeSignature;

    uint32_t            patchTableOffset;

    uint32_t            overrideBindTargetRefsOffset;
    uint32_t            overrideBindTargetRefsCount;

     struct section_locations    sectionLocations;
};

// https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/dyld/PrebuiltLoader.h#L344
// Stores information about the layout of the objc sections in a binary, as well as other properties relating to
// the objc information in there.
struct objc_binary_info {
    // Offset to the __objc_imageinfo section
    uint64_t imageInfoRuntimeOffset;

    // Offsets to sections containing objc pointers
    uint64_t selRefsRuntimeOffset;
    uint64_t classListRuntimeOffset;
    uint64_t categoryListRuntimeOffset;
    uint64_t protocolListRuntimeOffset;

    // Counts of the above sections.
    uint32_t selRefsCount;
    uint32_t classListCount;
    uint32_t categoryCount;
    uint32_t protocolListCount;

    // Do we have stable Swift fixups to apply to at least one class?
    bool     hasClassStableSwiftFixups;

    // Do we have any pointer-based method lists to set as uniqued?
    bool     hasClassMethodListsToSetUniqued;
    bool     hasCategoryMethodListsToSetUniqued;
    bool     hasProtocolMethodListsToSetUniqued;

    // Do we have any method lists in which to set selector references.
    // Note we only support visiting selector refernces in pointer based method lists
    // Relative method lists should have been verified to always point to __objc_selrefs
    bool     hasClassMethodListsToUnique;
    bool     hasCategoryMethodListsToUnique;
    bool     hasProtocolMethodListsToUnique;

    // Whwn serialized to the PrebuildLoader, these fields will encode other information about
    // the binary.

    // Offset to an array of uint8_t's.  One for each protocol.
    // Note this can be 0 (ie, have no fixups), even if we have protocols.  That would be the case
    // if this binary contains no canonical protocol definitions, ie, all canonical defs are in other binaries
    // or the shared cache.
    uint32_t protocolFixupsOffset;
    // Offset to an array of BindTargetRef's.  One for each selector reference to fix up
    // Note we only fix up selector refs in the __objc_selrefs section, and in pointer-based method lists
    uint32_t selectorReferencesFixupsOffset;
    uint32_t selectorReferencesFixupsCount;
};

#endif /* dyld_cache_loader_h */
