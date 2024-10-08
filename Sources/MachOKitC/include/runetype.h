/*-
 * Copyright (c) 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Paul Borman at Krystal Technologies.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)runetype.h	8.1 (Berkeley) 6/2/93
 */

#if !__has_include(<runetype.h>)

#ifndef	_RUNETYPE_H_
#define	_RUNETYPE_H_

#include "_types.h"
#include <wchar.h>

typedef wchar_t __darwin_rune_t;
typedef size_t __darwin_size_t;

#if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)

#ifndef	_SIZE_T
#define _SIZE_T
typedef	__darwin_size_t		size_t;
#endif

#ifndef	_CT_RUNE_T
#define _CT_RUNE_T
typedef	__darwin_ct_rune_t	ct_rune_t;
#endif

#ifndef	_RUNE_T
#define _RUNE_T
typedef	__darwin_rune_t		rune_t;
#endif

#ifndef	__cplusplus
#ifndef	_WCHAR_T
#define	_WCHAR_T
typedef	__darwin_wchar_t	wchar_t;
#endif	/* _WCHAR_T */
#endif	/* __cplusplus */

#ifndef	_WINT_T
#define _WINT_T
typedef	__darwin_wint_t		wint_t;
#endif

#endif /* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */

#define	_CACHED_RUNES	(1 <<8 )	/* Must be a power of 2 */
#define	_CRMASK		(~(_CACHED_RUNES - 1))

/*
 * The lower 8 bits of runetype[] contain the digit value of the rune.
 */
typedef struct {
	__darwin_rune_t	__min;		/* First rune of the range */
	__darwin_rune_t	__max;		/* Last rune (inclusive) of the range */
	__darwin_rune_t	__map;		/* What first maps to in maps */
	uint32_t	*__types;	/* Array of types in range */
} _RuneEntry;

typedef struct {
	int		__nranges;	/* Number of ranges stored */
	_RuneEntry	*__ranges;	/* Pointer to the ranges */
} _RuneRange;

typedef struct {
	char		__name[14];	/* CHARCLASS_NAME_MAX = 14 */
	uint32_t	__mask;		/* charclass mask */
} _RuneCharClass;

typedef struct {
	char		__magic[8];	/* Magic saying what version we are */
	char		__encoding[32];	/* ASCII name of this encoding */

	__darwin_rune_t	(*__sgetrune)(const char *, __darwin_size_t, char const **);
	int		(*__sputrune)(__darwin_rune_t, char *, __darwin_size_t, char **);
	__darwin_rune_t	__invalid_rune;

	uint32_t	__runetype[_CACHED_RUNES];
	__darwin_rune_t	__maplower[_CACHED_RUNES];
	__darwin_rune_t	__mapupper[_CACHED_RUNES];

	/*
	 * The following are to deal with Runes larger than _CACHED_RUNES - 1.
	 * Their data is actually contiguous with this structure so as to make
	 * it easier to read/write from/to disk.
	 */
	_RuneRange	__runetype_ext;
	_RuneRange	__maplower_ext;
	_RuneRange	__mapupper_ext;

	void		*__variable;	/* Data which depends on the encoding */
	int		__variable_len;	/* how long that data is */

	/*
	 * extra fields to deal with arbitrary character classes
	 */
	int		__ncharclasses;
	_RuneCharClass	*__charclasses;
} _RuneLocale;

#define	_RUNE_MAGIC_A	"RuneMagA"	/* Indicates version A of RuneLocale */

__BEGIN_DECLS
extern _RuneLocale _DefaultRuneLocale;
extern _RuneLocale *_CurrentRuneLocale;
__END_DECLS

#endif	/* !_RUNETYPE_H_ */

#endif
