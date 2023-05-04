\ mmap interface

\ Authors: Bernd Paysan, Anton Ertl
\ Copyright (C) 1998,2000,2003,2005,2006,2007,2008,2009,2010,2011,2013,2014,2015,2016,2019,2021,2022 Free Software Foundation, Inc.

\ This file is part of Gforth.

\ Gforth is free software; you can redistribute it and/or
\ modify it under the terms of the GNU General Public License
\ as published by the Free Software Foundation, either version 3
\ of the License, or (at your option) any later version.

\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\ GNU General Public License for more details.

\ You should have received a copy of the GNU General Public License
\ along with this program. If not, see http://www.gnu.org/licenses/.

c-library mmap
    \c #include <unistd.h>
    \c #include <sys/mman.h>
    \c #include <limits.h>

    c-function mmap mmap a n n n n n -- a ( addr len prot flags fd off -- addr' )
    c-function munmap munmap a n -- n ( addr len -- r )
    c-function madvise madvise a n n -- n ( addr len advice -- r )
    c-function mprotect mprotect a n n -- n ( addr len prot -- r )

    c-function mlock mlock a n -- n ( addr len -- r )
    c-function munlock munlock a n -- n ( addr len -- r )
    c-function msync msync a n n -- n ( vaddr len flags -- res )
e? os-type s" linux" string-prefix? [IF]
    c-function mremap mremap a n n n -- a ( addr len newlen flags -- addr' )
    e? os-type s" linux-gnu" string-prefix?
    e? os-type s" linux-musl" string-prefix? or [IF]
        c-function mremapf mremap a n n n a -- a ( addr len newlen flags newaddr -- addr' )
    [THEN]
[THEN]
end-c-library

require ./libc.fs

$0 Constant PROT_NONE		\ Page can not be accessed.
$1 Constant PROT_READ		\ Page can be read.
$2 Constant PROT_WRITE		\ Page can be written.
$3 Constant PROT_RW
$4 Constant PROT_EXEC		\ Page can be executed.
$7 Constant PROT_RWX
$01000000 Constant PROT_GROWSDOWN	\ Extend change to start of
                                        \  growsdown vma (mprotect only).
$02000000 Constant PROT_GROWSUP	\ Extend change to start of
                                        \ growsup vma (mprotect only).

$01 Constant MAP_SHARED		\ Share changes.
$02 Constant MAP_PRIVATE		\ Changes are private.
$10 Constant MAP_FIXED		\ Interpret addr exactly.
-1  Constant MAP_FAILED \ [MF|SHM] mmap failed

1 Constant MS_ASYNC
2 Constant MS_INVALIDATE
4 Constant MS_SYNC

s" os-type" environment? [IF]
    s" linux" string-prefix? [IF]
        \ Sharing types (must choose one and only one of these).

        0 Constant MAP_FILE
        machine "mips" str= [IF]
            $800  Constant MAP_ANONYMOUS
            $01000 Constant MAP_GROWSDOWN	\ Stack-like segment.
            $02000 Constant MAP_DENYWRITE	\ ETXTBSY
            $04000 Constant MAP_EXECUTABLE	\ Mark it as an executable.
            $08000 Constant MAP_LOCKED		\ Lock the mapping.
            $90400 Constant MAP_NORESERVE	\ Don't check for reservations.
            $10000 Constant MAP_POPULATE	\ Populate (prefault) pagetables
            $20000 Constant MAP_NONBLOCK	\ Do not block on IO.
            $40000 Constant MAP_STACK		\ Allocation is for a stack.
            $80000 Constant MAP_HUGETLB		\ Create huge page mapping.
        [ELSE]
            $20 Constant MAP_ANONYMOUS		\ Don't use a file.
            $00100 Constant MAP_GROWSDOWN	\ Stack-like segment.
            $00800 Constant MAP_DENYWRITE	\ ETXTBSY
            $01000 Constant MAP_EXECUTABLE	\ Mark it as an executable.
            $02000 Constant MAP_LOCKED		\ Lock the mapping.
            $04000 Constant MAP_NORESERVE	\ Don't check for reservations.
            $08000 Constant MAP_POPULATE	\ Populate (prefault) pagetables
            $10000 Constant MAP_NONBLOCK	\ Do not block on IO.
            $20000 Constant MAP_STACK		\ Allocation is for a stack.
            $40000 Constant MAP_HUGETLB		\ Create huge page mapping.
        [THEN]
        $40 Constant MAP_32BIT		\ Only give out 32-bit addresses.

        MAP_ANONYMOUS Constant MAP_ANON
    [THEN]
[THEN]

s" os-type" environment? [IF]
    s" cygwin" string-prefix? [IF]
        \ Sharing types (must choose one and only one of these).

        0 Constant MAP_FILE
        $20 Constant MAP_ANONYMOUS		\ Don't use a file.
        $4000 Constant MAP_NORESERVE            \ Don't reserve swap space for this mapping.
        $8000 Constant MAP_AUTOGROW             \ Grow underlying object to mapping size.
        MAP_ANONYMOUS Constant MAP_ANON
    [THEN]
[THEN]

s" os-type" environment? [IF]
    2dup s" darwin" string-prefix? -rot s" bsd" search nip nip or [IF]
        $0020 Constant MAP_RENAME \ Sun: rename private pages to file
        $0040 Constant MAP_NORESERVE \ Sun: don't reserve needed swap area
        $0080 Constant MAP_RESERVED0080 \ previously unimplemented MAP_INHERIT
        $0100 Constant MAP_NOEXTEND \ for MAP_FILE, don't change file size
        $0200 Constant MAP_HASSEMAPHORE \ region may contain semaphores
        $0400 Constant MAP_NOCACHE \ don't cache pages for this mapping
        $0800 Constant MAP_JIT \ Allocate a region that will be used for JIT purposes
        $0000 Constant MAP_FILE \ map from file (default)
        $1000 Constant MAP_ANON \ allocated from memory, swap space
        MAP_ANON Constant MAP_ANONYMOUS
    [THEN]
[THEN]

1 Constant MREMAP_MAYMOVE
2 Constant MREMAP_FIXED

\ Advice to `madvise'.
#0 Constant MADV_NORMAL		\ No further special treatment.
#1 Constant MADV_RANDOM		\ Expect random page references.
#2 Constant MADV_SEQUENTIAL	\ Expect sequential page references.
#3 Constant MADV_WILLNEED	\ Will need these pages.
#4 Constant MADV_DONTNEED	\ Don't need these pages.
#9 Constant MADV_REMOVE		\ Remove these pages and resources.
#10 Constant MADV_DONTFORK	\ Do not inherit across fork.
#11 Constant MADV_DOFORK		\ Do inherit across fork.
#12 Constant MADV_MERGEABLE	\ KSM may merge identical pages.
#13 Constant MADV_UNMERGEABLE	\ KSM may not merge identical pages.
#14 Constant MADV_HUGEPAGE	\ Worth backing with hugepages.
#15 Constant MADV_NOHUGEPAGE	\ Not worth backing with hugepages.
#100 Constant MADV_HWPOISON	\ Poison a page for testing.

: >pagealign ( addr -- p-addr )
    pagesize 1- + pagesize negate and ;

: alloc+guard ( len -- addr )
    >pagealign dup >r pagesize +
    0 swap PROT_RWX
    [ MAP_PRIVATE MAP_ANONYMOUS or ]L -1 0 mmap dup ?ior
    dup r> + pagesize PROT_NONE mprotect ?ior ;
: alloc+lock ( len -- addr )
    >pagealign dup >r alloc+guard dup r> mlock ?ior ;

: free+guard ( addr len -- )
    >pagealign pagesize + munmap ?ior ;

: clearpages ( addr len -- ) >pagealign
    2dup munmap ?ior
    PROT_RWX
    [ MAP_PRIVATE MAP_ANONYMOUS or MAP_FIXED or ]L -1 0 mmap 0= ?ior ;

: map-fid ( fid -- addr u )
    dup >r file-size throw d>s 0 over PROT_RW MAP_SHARED r@ fileno 0 mmap
    dup ?ior swap r> close-file throw ;
: map-fid-private ( fid -- addr u )
    dup >r file-size throw d>s 0 over PROT_RW MAP_PRIVATE r@ fileno 0 mmap
    dup ?ior swap r> close-file throw ;

: map-file ( addr1 u1 fam -- addr2 u2 )
    open-file throw dup >r ['] map-fid catch
    dup IF  r@ close-file throw  THEN  rdrop throw ;
: map-file-private ( addr1 u1 fam -- addr2 u2 )
    open-file throw dup >r ['] map-fid-private catch
    dup IF  r@ close-file throw  THEN  rdrop throw ;

: unmap ( addr u -- )  munmap ?ior ;
