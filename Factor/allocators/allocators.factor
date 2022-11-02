! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: allocators

USING: typed kernel math unix.ffi locals
       alien alien.data alien.syntax
       make
       libc
       sequences
       namespaces
       accessors ;
QUALIFIED-WITH: unix.ffi ffi
QUALIFIED-WITH: alien.c-types c

: K ( size: c:ulonglong -- size: c:ulonglong ) 1024 * ;
: M ( size: c:ulonglong -- size: c:ulonglong ) 1048576 * ;
: G ( size: c:ulonglong -- size: c:ulonglong ) 1073741824 * ;

! Taken from
! https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/

! --------------------------------------------------------------------------------
! Most Basic Allocator
! --------------------------------------------------------------------------------
SYMBOL: arena-buffer
SYMBOL: arena-buffer-length
SYMBOL: arena-offset

arena-offset [ 0 ] initialize

arena-buffer-length [ 1 M ] initialize

arena-buffer [ arena-buffer-length get c:char malloc-array ] initialize

: deallocate ( memory: c:void* size: c:size_t -- c:int ) munmap ;

:: index-address ( c-type index address -- address )
    c-type c:heap-size index * address <displaced-alien> ;

TYPED:: global-arena-alloc ( size: fixnum --  ptr )
    arena-buffer get >c-ptr :> address
    arena-offset get        :> offset
    arena-buffer-length get :> arena-length
    size offset + arena-length <=
    [ size arena-offset +@
      ! Zero out the memory location by default
      c:char offset address index-address
      dup 0 size memset
    ]
    ! return f if the arena is out of memory
    [ f ]
    if ;

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

TYPED:: arena-alloc-align ( arena: arena size: fixnum align: fixnum -- alien )
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

TYPED: arena-alloc ( a: arena size: fixnum -- alien )
    default-alignment arena-alloc-align ;

! do nothing
: arena-free ( arena ptr -- ) 2drop ;

! in factor this really calls calloc, so really malloc based
! since it is prohibited otherwise
: arena-array ( -- ) ;

: arena-malloc ( -- ) ;
