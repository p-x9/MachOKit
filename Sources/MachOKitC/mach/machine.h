/*
 * Copyright (c) 2000-2007 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 *
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */
/*
 * Mach Operating System
 * Copyright (c) 1991,1990,1989,1988,1987 Carnegie Mellon University
 * All Rights Reserved.
 *
 * Permission to use, copy, modify and distribute this software and its
 * documentation is hereby granted, provided that both the copyright
 * notice and this permission notice appear in all copies of the
 * software, derivative works or modified versions, and any portions
 * thereof, and that both notices appear in supporting documentation.
 *
 * CARNEGIE MELLON ALLOWS FREE USE OF THIS SOFTWARE IN ITS "AS IS"
 * CONDITION.  CARNEGIE MELLON DISCLAIMS ANY LIABILITY OF ANY KIND FOR
 * ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
 *
 * Carnegie Mellon requests users of this software to return to
 *
 *  Software Distribution Coordinator  or  Software.Distribution@CS.CMU.EDU
 *  School of Computer Science
 *  Carnegie Mellon University
 *  Pittsburgh PA 15213-3890
 *
 * any improvements or extensions that they make and grant Carnegie Mellon
 * the rights to redistribute these changes.
 */
/*	File:	machine.h
 *	Author:	Avadis Tevanian, Jr.
 *	Date:	1986
 *
 *	Machine independent machine abstraction.
 */

#ifndef	_MACH_MACHINE_H_
#define _MACH_MACHINE_H_

typedef int32_t cpu_type_t;
typedef int32_t cpu_subtype_t;

#define CPU_STATE_MAX		4

#define CPU_STATE_USER		0
#define CPU_STATE_NICE		1
#define CPU_STATE_SYSTEM	2
#define CPU_STATE_IDLE		3

/*
 *	Machine types known by all.
 *
 *	When adding new types & subtypes, please also update slot_name.c
 *	in the libmach sources.
 */

/*
 * Capability bits used in the definition of cpu_type.
 */
#define CPU_ARCH_MASK           ((cpu_subtype_t) 0xff000000)      /* mask for architecture bits */
#define CPU_ARCH_ABI64          ((cpu_subtype_t) 0x01000000)      /* 64 bit ABI */
#define CPU_ARCH_ABI64_32       ((cpu_subtype_t) 0x02000000)      /* ABI for 64-bit hardware with 32-bit types; LP32 */

/*
 *	Machine types known by all.
 */

#define CPU_TYPE_ANY            ((cpu_type_t) -1)

/*
 *	Object files that are hand-crafted to run on any
 *	implementation of an architecture are tagged with
 *	CPU_SUBTYPE_MULTIPLE.  This functions essentially the same as
 *	the "ALL" subtype of an architecture except that it allows us
 *	to easily find object files that may need to be modified
 *	whenever a new implementation of an architecture comes out.
 *
 *	It is the responsibility of the implementor to make sure the
 *	software handles unsupported implementations elegantly.
 */
#define CPU_SUBTYPE_MULTIPLE            ((cpu_subtype_t) -1)
#define CPU_SUBTYPE_LITTLE_ENDIAN       ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_BIG_ENDIAN          ((cpu_subtype_t) 1)

/*
 *     Machine threadtypes.
 *     This is none - not defined - for most machine types/subtypes.
 */
#define CPU_THREADTYPE_NONE             ((cpu_threadtype_t) 0)

#define CPU_TYPE_VAX            ((cpu_type_t) 1)
/* skip				((cpu_type_t) 2)	*/
/* skip				((cpu_type_t) 3)	*/
/* skip				((cpu_type_t) 4)	*/
/* skip				((cpu_type_t) 5)	*/
#define CPU_TYPE_MC680x0        ((cpu_type_t) 6)
#define CPU_TYPE_X86            ((cpu_type_t) 7)
#define CPU_TYPE_I386           CPU_TYPE_X86            /* compatibility */
#define CPU_TYPE_X86_64         (CPU_TYPE_X86 | CPU_ARCH_ABI64)

/* skip CPU_TYPE_MIPS		((cpu_type_t) 8)	*/
/* skip                         ((cpu_type_t) 9)	*/
#define CPU_TYPE_MC98000        ((cpu_type_t) 10)
#define CPU_TYPE_HPPA           ((cpu_type_t) 11)
#define CPU_TYPE_ARM            ((cpu_type_t) 12)
#define CPU_TYPE_ARM64          (CPU_TYPE_ARM | CPU_ARCH_ABI64)
#define CPU_TYPE_ARM64_32       (CPU_TYPE_ARM | CPU_ARCH_ABI64_32)
#define CPU_TYPE_MC88000        ((cpu_type_t) 13)
#define CPU_TYPE_SPARC          ((cpu_type_t) 14)
#define CPU_TYPE_I860           ((cpu_type_t) 15)
/* skip	CPU_TYPE_ALPHA		((cpu_type_t) 16)	*/
/* skip				((cpu_type_t) 17)	*/
#define CPU_TYPE_POWERPC                ((cpu_type_t) 18)
#define CPU_TYPE_POWERPC64              (CPU_TYPE_POWERPC | CPU_ARCH_ABI64)
/* skip				((cpu_type_t) 19)	*/
/* skip				((cpu_type_t) 20 */
/* skip				((cpu_type_t) 21 */
/* skip				((cpu_type_t) 22 */
/* skip				((cpu_type_t) 23 */

/*
 *	Machine subtypes (these are defined here, instead of in a machine
 *	dependent directory, so that any program can get all definitions
 *	regardless of where is it compiled).
 */

/*
 *	VAX subtypes (these do *not* necessarily conform to the actual cpu
 *	ID assigned by DEC available via the SID register).
 */
#define CPU_SUBTYPE_MASK        0xff000000
#define CPU_SUBTYPE_VAX_ALL     ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_VAX780	((cpu_subtype_t) 1)
#define CPU_SUBTYPE_VAX785	((cpu_subtype_t) 2)
#define CPU_SUBTYPE_VAX750	((cpu_subtype_t) 3)
#define CPU_SUBTYPE_VAX730	((cpu_subtype_t) 4)
#define CPU_SUBTYPE_UVAXI	((cpu_subtype_t) 5)
#define CPU_SUBTYPE_UVAXII	((cpu_subtype_t) 6)
#define CPU_SUBTYPE_VAX8200	((cpu_subtype_t) 7)
#define CPU_SUBTYPE_VAX8500	((cpu_subtype_t) 8)
#define CPU_SUBTYPE_VAX8600	((cpu_subtype_t) 9)
#define CPU_SUBTYPE_VAX8650	((cpu_subtype_t) 10)
#define CPU_SUBTYPE_VAX8800	((cpu_subtype_t) 11)
#define CPU_SUBTYPE_UVAXIII	((cpu_subtype_t) 12)

/*
 *	Alpha subtypes (these do *not* necessary conform to the actual cpu
 *	ID assigned by DEC available via the SID register).
 */

#define CPU_SUBTYPE_ALPHA_ADU		((cpu_subtype_t) 1)
#define CPU_SUBTYPE_DEC_4000		((cpu_subtype_t) 2)
#define CPU_SUBTYPE_DEC_7000		((cpu_subtype_t) 3)
#define CPU_SUBTYPE_DEC_3000_500	((cpu_subtype_t) 4)
#define CPU_SUBTYPE_DEC_3000_400	((cpu_subtype_t) 5)
#define CPU_SUBTYPE_DEC_10000		((cpu_subtype_t) 6)
#define CPU_SUBTYPE_DEC_3000_300        ((cpu_subtype_t) 7)
#define CPU_SUBTYPE_DEC_2000_300        ((cpu_subtype_t) 8)
#define CPU_SUBTYPE_DEC_2100_A500	((cpu_subtype_t) 9)
#define CPU_SUBTYPE_DEC_MORGAN		((cpu_subtype_t) 11)
#define CPU_SUBTYPE_DEC_AVANTI          ((cpu_subtype_t) 13)
#define CPU_SUBTYPE_DEC_MUSTANG         ((cpu_subtype_t) 14)

/*
 *	ROMP subtypes.
 */

#define CPU_SUBTYPE_RT_PC	((cpu_subtype_t) 1)
#define CPU_SUBTYPE_RT_APC	((cpu_subtype_t) 2)
#define CPU_SUBTYPE_RT_135	((cpu_subtype_t) 3)

/*
 *	68020 subtypes.
 */

#define CPU_SUBTYPE_SUN3_50	((cpu_subtype_t) 1)
#define CPU_SUBTYPE_SUN3_160	((cpu_subtype_t) 2)
#define CPU_SUBTYPE_SUN3_260	((cpu_subtype_t) 3)
#define CPU_SUBTYPE_SUN3_110	((cpu_subtype_t) 4)
#define CPU_SUBTYPE_SUN3_60	((cpu_subtype_t) 5)

#define CPU_SUBTYPE_HP_320	((cpu_subtype_t) 6)
	/* 16.67 Mhz HP 300 series, custom MMU [HP 320] */
#define CPU_SUBTYPE_HP_330	((cpu_subtype_t) 7)
	/* 16.67 Mhz HP 300 series, MC68851 MMU [HP 318,319,330,349] */
#define CPU_SUBTYPE_HP_350	((cpu_subtype_t) 8)
	/* 25.00 Mhz HP 300 series, custom MMU [HP 350] */

/*
 *	32032/32332/32532 subtypes.
 */

#define CPU_SUBTYPE_MMAX_DPC	    ((cpu_subtype_t) 1)	/* 032 CPU */
#define CPU_SUBTYPE_SQT		    ((cpu_subtype_t) 2) /* Symmetry */
#define CPU_SUBTYPE_MMAX_APC_FPU    ((cpu_subtype_t) 3)	/* 32081 FPU */
#define CPU_SUBTYPE_MMAX_APC_FPA    ((cpu_subtype_t) 4)	/* Weitek FPA */
#define CPU_SUBTYPE_MMAX_XPC	    ((cpu_subtype_t) 5)	/* 532 CPU */
#define CPU_SUBTYPE_SQT86	    ((cpu_subtype_t) 6) /* ?? */

/*
 *      680x0 subtypes
 *
 * The subtype definitions here are unusual for historical reasons.
 * NeXT used to consider 68030 code as generic 68000 code.  For
 * backwards compatability:
 *
 *	CPU_SUBTYPE_MC68030 symbol has been preserved for source code
 *	compatability.
 *
 *	CPU_SUBTYPE_MC680x0_ALL has been defined to be the same
 *	subtype as CPU_SUBTYPE_MC68030 for binary comatability.
 *
 *	CPU_SUBTYPE_MC68030_ONLY has been added to allow new object
 *	files to be tagged as containing 68030-specific instructions.
 */

#define CPU_SUBTYPE_MC680x0_ALL         ((cpu_subtype_t) 1)
#define CPU_SUBTYPE_MC68030             ((cpu_subtype_t) 1) /* compat */
#define CPU_SUBTYPE_MC68040             ((cpu_subtype_t) 2)
#define CPU_SUBTYPE_MC68030_ONLY        ((cpu_subtype_t) 3)

/*
 *	X86 & X86_64 subtypes.
 */

#define CPU_SUBTYPE_I386_ALL		((cpu_subtype_t) 3)
#define CPU_SUBTYPE_386			CPU_SUBTYPE_I386_ALL
#define CPU_SUBTYPE_486			((cpu_subtype_t) 4)
#define CPU_SUBTYPE_486SX		((cpu_subtype_t) 0x84)
#define CPU_SUBTYPE_586			((cpu_subtype_t) 5)
#define CPU_SUBTYPE_PENT		CPU_SUBTYPE_586
#define CPU_SUBTYPE_PENTPRO		((cpu_subtype_t) 0x16)
#define CPU_SUBTYPE_PENTII_M3		((cpu_subtype_t) 0x36)
#define CPU_SUBTYPE_PENTII_M5		((cpu_subtype_t) 0x56)
#define CPU_SUBTYPE_CELERON		((cpu_subtype_t) 0x67)
#define CPU_SUBTYPE_CELERON_MOBILE	((cpu_subtype_t) 0x77)
#define CPU_SUBTYPE_PENTIUM_3		((cpu_subtype_t) 0x08)
#define CPU_SUBTYPE_PENTIUM_3_M		((cpu_subtype_t) 0x18)
#define CPU_SUBTYPE_PENTIUM_3_XEON	((cpu_subtype_t) 0x28)
#define CPU_SUBTYPE_PENTIUM_M		((cpu_subtype_t) 0x09)
#define CPU_SUBTYPE_PENTIUM_4		((cpu_subtype_t) 0x0a)
#define CPU_SUBTYPE_PENTIUM_4_M		((cpu_subtype_t) 0x1a)
#define CPU_SUBTYPE_ITANIUM		((cpu_subtype_t) 0x0b)
#define CPU_SUBTYPE_ITANIUM_2		((cpu_subtype_t) 0x1b)
#define CPU_SUBTYPE_XEON		((cpu_subtype_t) 0x0c)
#define CPU_SUBTYPE_XEON_MP		((cpu_subtype_t) 0x1c)

#define CPU_SUBTYPE_X86_ALL		((cpu_subtype_t) 3)
#define CPU_SUBTYPE_X86_64_ALL		((cpu_subtype_t) 3)
#define CPU_SUBTYPE_X86_ARCH1		((cpu_subtype_t) 4)
#define CPU_SUBTYPE_X86_64_H		((cpu_subtype_t) 8)

#define CPU_SUBTYPE_INTEL_FAMILY_MAX	((cpu_subtype_t) 15)
#define CPU_SUBTYPE_INTEL_MODEL_ALL	((cpu_subtype_t) 0)

inline int CPU_SUBTYPE_INTEL(int family, int model) {
    return family | (model << 4);
}

inline int CPU_SUBTYPE_INTEL_FAMILY(cpu_subtype_t subtype) {
    return ((int)subtype & 0x0f);
}

inline int CPU_SUBTYPE_INTEL_MODEL(cpu_subtype_t subtype) {
    return ((int)subtype >> 4);
}
#define CPU_THREADTYPE_INTEL_HTT        ((cpu_threadtype_t) 1)

/*
 *	Mips subtypes.
 */

#define CPU_SUBTYPE_MIPS_ALL    ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_MIPS_R2300  ((cpu_subtype_t) 1)
#define CPU_SUBTYPE_MIPS_R2600  ((cpu_subtype_t) 2)
#define CPU_SUBTYPE_MIPS_R2800  ((cpu_subtype_t) 3)
#define CPU_SUBTYPE_MIPS_R2000a ((cpu_subtype_t) 4)     /* pmax */
#define CPU_SUBTYPE_MIPS_R2000  ((cpu_subtype_t) 5)
#define CPU_SUBTYPE_MIPS_R3000a ((cpu_subtype_t) 6)     /* 3max */
#define CPU_SUBTYPE_MIPS_R3000  ((cpu_subtype_t) 7)

/*
 *	MC98000 (PowerPC) subtypes
 */
#define CPU_SUBTYPE_MC98000_ALL ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_MC98601     ((cpu_subtype_t) 1)

/*
 *	HPPA subtypes for Hewlett-Packard HP-PA family of
 *	risc processors. Port by NeXT to 700 series.
 */

#define CPU_SUBTYPE_HPPA_ALL            ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_HPPA_7100           ((cpu_subtype_t) 0) /* compat */
#define CPU_SUBTYPE_HPPA_7100LC         ((cpu_subtype_t) 1)

/*
 *	MC88000 subtypes.
 */
#define CPU_SUBTYPE_MC88000_ALL ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_MC88100     ((cpu_subtype_t) 1)
#define CPU_SUBTYPE_MC88110     ((cpu_subtype_t) 2)

/*
 *	SPARC subtypes
 */
#define CPU_SUBTYPE_SPARC_ALL           ((cpu_subtype_t) 0)

/*
 *	I860 subtypes
 */
#define CPU_SUBTYPE_I860_ALL    ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_I860_860    ((cpu_subtype_t) 1)

/*
 *	PowerPC subtypes
 */
#define CPU_SUBTYPE_POWERPC_ALL         ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_POWERPC_601         ((cpu_subtype_t) 1)
#define CPU_SUBTYPE_POWERPC_602         ((cpu_subtype_t) 2)
#define CPU_SUBTYPE_POWERPC_603         ((cpu_subtype_t) 3)
#define CPU_SUBTYPE_POWERPC_603e        ((cpu_subtype_t) 4)
#define CPU_SUBTYPE_POWERPC_603ev       ((cpu_subtype_t) 5)
#define CPU_SUBTYPE_POWERPC_604         ((cpu_subtype_t) 6)
#define CPU_SUBTYPE_POWERPC_604e        ((cpu_subtype_t) 7)
#define CPU_SUBTYPE_POWERPC_620         ((cpu_subtype_t) 8)
#define CPU_SUBTYPE_POWERPC_750         ((cpu_subtype_t) 9)
#define CPU_SUBTYPE_POWERPC_7400        ((cpu_subtype_t) 10)
#define CPU_SUBTYPE_POWERPC_7450        ((cpu_subtype_t) 11)
#define CPU_SUBTYPE_POWERPC_970         ((cpu_subtype_t) 100)

/*
 *	ARM subtypes
 */
#define CPU_SUBTYPE_ARM_ALL             ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_ARM_V4T             ((cpu_subtype_t) 5)
#define CPU_SUBTYPE_ARM_V6              ((cpu_subtype_t) 6)
#define CPU_SUBTYPE_ARM_V5TEJ           ((cpu_subtype_t) 7)
#define CPU_SUBTYPE_ARM_XSCALE          ((cpu_subtype_t) 8)
#define CPU_SUBTYPE_ARM_V7              ((cpu_subtype_t) 9)  /* ARMv7-A and ARMv7-R */
#define CPU_SUBTYPE_ARM_V7F             ((cpu_subtype_t) 10) /* Cortex A9 */
#define CPU_SUBTYPE_ARM_V7S             ((cpu_subtype_t) 11) /* Swift */
#define CPU_SUBTYPE_ARM_V7K             ((cpu_subtype_t) 12)
#define CPU_SUBTYPE_ARM_V8              ((cpu_subtype_t) 13)
#define CPU_SUBTYPE_ARM_V6M             ((cpu_subtype_t) 14) /* Not meant to be run under xnu */
#define CPU_SUBTYPE_ARM_V7M             ((cpu_subtype_t) 15) /* Not meant to be run under xnu */
#define CPU_SUBTYPE_ARM_V7EM            ((cpu_subtype_t) 16) /* Not meant to be run under xnu */
#define CPU_SUBTYPE_ARM_V8M             ((cpu_subtype_t) 17) /* Not meant to be run under xnu */

/*
 *  ARM64 subtypes
 */
#define CPU_SUBTYPE_ARM64_ALL           ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_ARM64_V8            ((cpu_subtype_t) 1)
#define CPU_SUBTYPE_ARM64E              ((cpu_subtype_t) 2)

/* CPU subtype feature flags for ptrauth on arm64e platforms */
#define CPU_SUBTYPE_ARM64_PTR_AUTH_MASK ((cpu_subtype_t) 0x0f000000)
#define CPU_SUBTYPE_ARM64_PTR_AUTH_VERSION(x) (((x) & CPU_SUBTYPE_ARM64_PTR_AUTH_MASK) >> 24)

/*
 *  ARM64_32 subtypes
 */
#define CPU_SUBTYPE_ARM64_32_ALL        ((cpu_subtype_t) 0)
#define CPU_SUBTYPE_ARM64_32_V8 ((cpu_subtype_t) 1)

#endif	/* _MACH_MACHINE_H_ */
