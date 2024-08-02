#ifdef __linux__

#ifndef MACH_O_LINUX_H_
#define MACH_O_LINUX_H_

#include <stdbool.h>
#include <string.h>

#include "mach-o/fat.h"
#include "mach-o/loader.h"
#include "mach-o/nlist.h"
#include "mach-o/reloc.h"
#include "mach-o/stab.h"
#include "mach/vm_prot.h"

// Byte order stuff
#ifndef OS_INLINE
#define OS_INLINE static __inline__
#endif

enum NXByteOrder {
    NX_UnknownByteOrder,
    NX_LittleEndian,
    NX_BigEndian
};

OS_INLINE
uint16_t OSSwapInt16(uint16_t data);

OS_INLINE
uint32_t OSSwapInt32(uint32_t data);

OS_INLINE
uint64_t OSSwapInt64(uint64_t data);

static __inline__
enum NXByteOrder
NXHostByteOrder(void)
{
#if defined(__LITTLE_ENDIAN__)
    return NX_LittleEndian;
#elif defined(__BIG_ENDIAN__)
    return NX_BigEndian;
#else
    return NX_UnknownByteOrder;
#endif
}

void
swap_fat_header(
struct fat_header *fat_header,
enum NXByteOrder target_byte_sex);

void
swap_fat_arch(
struct fat_arch *fat_archs,
uint32_t nfat_arch,
enum NXByteOrder target_byte_sex);

void
swap_fat_arch_64(
struct fat_arch_64 *fat_archs64,
uint32_t nfat_arch,
enum NXByteOrder target_byte_sex);

void
swap_mach_header(
struct mach_header *mh,
enum NXByteOrder target_byte_sex);

void
swap_mach_header_64(
struct mach_header_64 *mh,
enum NXByteOrder target_byte_sex);

void
swap_load_command(
struct load_command *lc,
enum NXByteOrder target_byte_sex);

void
swap_segment_command(
struct segment_command *sg,
enum NXByteOrder target_byte_sex);

void 
swap_segment_command_64(
struct segment_command_64* sg,
enum NXByteOrder target_byte_sex);

void
swap_section(
struct section *s,
uint32_t nsects,
enum NXByteOrder target_byte_sex);

void
swap_section_64(
struct section_64 *s,
uint32_t nsects,
enum NXByteOrder target_byte_sex);

void
swap_symtab_command(
struct symtab_command *st,
enum NXByteOrder target_byte_sex);

void
swap_dysymtab_command(
struct dysymtab_command *dyst,
enum NXByteOrder target_byte_sex);

void
swap_symseg_command(
struct symseg_command *ss,
enum NXByteOrder target_byte_sex);

void
swap_fvmlib_command(
struct fvmlib_command *fl,
enum NXByteOrder target_byte_sex);

void
swap_dylib_command(
struct dylib_command *dl,
enum NXByteOrder target_byte_sex);

void
swap_sub_framework_command(
struct sub_framework_command *sub,
enum NXByteOrder target_byte_sex);

void
swap_sub_umbrella_command(
struct sub_umbrella_command *usub,
enum NXByteOrder target_byte_sex);

void
swap_sub_library_command(
struct sub_library_command *lsub,
enum NXByteOrder target_byte_sex);

void
swap_sub_client_command(
struct sub_client_command *csub,
enum NXByteOrder target_byte_sex);

void
swap_prebound_dylib_command(
struct prebound_dylib_command *pbdylib,
enum NXByteOrder target_byte_sex);

void
swap_dylinker_command(
struct dylinker_command *dyld,
enum NXByteOrder target_byte_sex);

void
swap_fvmfile_command(
struct fvmfile_command *ff,
enum NXByteOrder target_byte_sex);

void
swap_thread_command(
struct thread_command *ut,
enum NXByteOrder target_byte_sex);

void
swap_ident_command(
struct ident_command *id_cmd,
enum NXByteOrder target_byte_sex);

void
swap_routines_command(
struct routines_command *r_cmd,
enum NXByteOrder target_byte_sex);

void
swap_routines_command_64(
struct routines_command_64 *r_cmd,
enum NXByteOrder target_byte_sex);

void
swap_twolevel_hints_command(
struct twolevel_hints_command *hints_cmd,
enum NXByteOrder target_byte_sex);

void
swap_twolevel_hint(
struct twolevel_hint *hints,
uint32_t nhints,
enum NXByteOrder target_byte_sex);

void
swap_prebind_cksum_command(
struct prebind_cksum_command *cksum_cmd,
enum NXByteOrder target_byte_sex);

void
swap_uuid_command(
struct uuid_command *uuid_cmd,
enum NXByteOrder target_byte_sex);

void
swap_linkedit_data_command(
struct linkedit_data_command *ld,
enum NXByteOrder target_byte_sex);

void
swap_version_min_command(
struct version_min_command *ver_cmd,
enum NXByteOrder target_byte_sex);

void
swap_build_version_command(
struct build_version_command *bv,
enum NXByteOrder target_byte_sex);

void
swap_build_tool_version(
struct build_tool_version *btv,
uint32_t ntools,
enum NXByteOrder target_byte_sex);

void
swap_rpath_command(
struct rpath_command *rpath_cmd,
enum NXByteOrder target_byte_sex);

void
swap_encryption_command(
struct encryption_info_command *ec,
enum NXByteOrder target_byte_sex);

void
swap_encryption_command_64(
struct encryption_info_command_64 *ec,
enum NXByteOrder target_byte_sex);

void
swap_linker_option_command(
struct linker_option_command *lo,
enum NXByteOrder target_byte_sex);

void
swap_dyld_info_command(
struct dyld_info_command *ed,
enum NXByteOrder target_byte_sex);

void
swap_entry_point_command(
struct entry_point_command *ep,
enum NXByteOrder target_byte_sex);

void
swap_source_version_command(
struct source_version_command *sv,
enum NXByteOrder target_byte_sex);

void
swap_note_command(
struct note_command *nc,
enum NXByteOrder target_byte_sex);

void
swap_fileset_entry_command(
struct fileset_entry_command *lc,
enum NXByteOrder target_byte_sex);

void
swap_nlist(
struct nlist *symbols,
uint32_t nsymbols,
enum NXByteOrder target_byte_sex);

void
swap_nlist_64(
struct nlist_64 *symbols,
uint32_t nsymbols,
enum NXByteOrder target_byte_sex);

void
swap_relocation_info(
struct relocation_info *relocs,
uint32_t nrelocs,
enum NXByteOrder target_byte_sex);

void
swap_indirect_symbols(
uint32_t *indirect_symbols,
uint32_t nindirect_symbols,
enum NXByteOrder target_byte_sex);

void
swap_dylib_reference(
struct dylib_reference *refs,
uint32_t nrefs,
enum NXByteOrder target_byte_sex);

void
swap_dylib_module(
struct dylib_module *mods,
uint32_t nmods,
enum NXByteOrder target_byte_sex);

void
swap_dylib_module_64(
struct dylib_module_64 *mods,
uint32_t nmods,
enum NXByteOrder target_byte_sex);

void
swap_dylib_table_of_contents(
struct dylib_table_of_contents *tocs,
uint32_t ntocs,
enum NXByteOrder target_byte_sex);

#endif
#endif