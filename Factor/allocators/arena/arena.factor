! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: typed kernel math unix.ffi locals
       alien alien.data alien.syntax
       make
       libc
       sequences
       namespaces
       accessors
       ;

QUALIFIED: libc
QUALIFIED-WITH: alien.c-types c

IN: allocators.arena

: K ( size: c:ulonglong -- size: c:ulonglong ) 1024 * ;
: M ( size: c:ulonglong -- size: c:ulonglong ) 1048576 * ;
: G ( size: c:ulonglong -- size: c:ulonglong ) 1073741824 * ;

! Taken from
! https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/

! --------------------------------------------------------------------------------
! More Proper Allocator
! --------------------------------------------------------------------------------

: is-power-of-two? ( address -- aligned? )
    dup 1 - bitand 0 = ;

: assert-power-of-two ( address -- address )
    dup is-power-of-two? t assert= ;

! same as ptr align mod but bitand is faster if align is a power of 2
: mod-power-two ( value power -- modded-value )
    1 - bitand ; inline

TYPED: align-forward ( align: fixnum ptr: alien -- aligned-ptr: alien )
    alien-address swap assert-power-of-two
    ! if the address isn't aligned, then push the address the next
    ! address which is aligned
    2dup mod-power-two [ drop ] [ - + ] if-zero <alien> ;

! Why do we 2 times the size of void*?
: default-alignment ( -- fixnum ) c:void* c:heap-size 2 * ;

TUPLE: arena
    { buffer        alien }
    { buffer-length fixnum }
    { prev-offset   fixnum initial: 0 }
    { curr-offset   fixnum initial: 0 } ;

TYPED: <arena> ( data: alien length: fixnum --  arena: arena )
    0 0 arena boa ;

TYPED: current-address ( arena: arena -- current: alien )
    [ buffer>> alien-address ] [ curr-offset>> ] bi + <alien> ;

TYPED: offset-from-base ( forward-addr: alien a: arena -- offset-from-base: fixnum )
    buffer>> [ alien-address ] bi@ - ;

: nearest-align ( align arena -- address )
    current-address align-forward ;

TYPED:: alloc-align ( arena: arena size: fixnum align: fixnum -- alien )
    ! Get the relative offset
    align   arena nearest-align    :> new-ptr
    new-ptr arena offset-from-base :> offset
    offset size + arena buffer-length>> <=
    ! see if we have memory left
    [ arena offset >>prev-offset offset size + >>curr-offset drop
      new-ptr dup 0 size memset
    ]
    [ f ]
    if ;

TYPED: alloc ( a: arena size: fixnum -- alien )
    default-alignment alloc-align ;

! do nothing
: free ( arena ptr -- ) 2drop ;


: free-all ( arena -- ) 0 >>curr-offset 0 >>prev-offset drop ;

! backs our memory allocator via a malloc
! we can't back it via an array as the GC would take it ☹
: arena-malloc ( size -- arena ) [ malloc ] keep <arena> ;

! unmallocs a malloc backed arena
: arena-free-malloc ( arena -- ) buffer>> libc:free ;

! we could also back it via a mmap

