! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: typed kernel math unix.ffi locals
       alien alien.data alien.syntax make libc
       sequences namespaces accessors combinators math.order ;
QUALIFIED: libc
QUALIFIED-WITH: alien.c-types c

IN: allocators.arena

! Taken from
! https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/

! Missing FFI Functions
LIBRARY: libc
FUNCTION: c:void* memmove ( c:void* dst, c:void* src, c:size_t size )

TUPLE: arena
    { buffer        alien }
    { buffer-length fixnum }
    { prev-offset   fixnum initial: 0 }
    { curr-offset   fixnum initial: 0 } ;

! Why do we 2 times the size of void*?
: default-alignment ( -- fixnum ) c:void* c:heap-size 2 * ;

TYPED: current-address ( arena: arena -- current: alien )
    [ buffer>> alien-address ] [ curr-offset>> ] bi + <alien> ;

! Utility Functions

<PRIVATE

: power-of-two? ( address -- aligned? )
    dup 1 - bitand 0 = ;

: assert-power-of-two ( address -- address )
    dup power-of-two? t assert= ;

! same as ptr align mod but bitand is faster if align is a power of 2
: mod-power-two ( value power -- modded-value )
    1 - bitand ; inline

TYPED: align-forward ( align: fixnum ptr: alien -- aligned-ptr: alien )
    alien-address swap assert-power-of-two
    ! if the address is aligned, then return it, otherwise align the address
    ! (I.E. adding align - mod + address. since align - mod = bits to align)
    2dup mod-power-two [ drop ] [ - + ] if-zero <alien> ;

TYPED: offset-from-base ( forward-addr: alien a: arena -- offset-from-base: fixnum )
    buffer>> [ alien-address ] bi@ - ;

: nearest-align ( align arena -- address ) current-address align-forward ;

: past-bounds? ( arena offset size -- past? ) + swap buffer-length>> > ;

TYPED: below-bounds? ( a: arena memory: alien -- below? )
    swap buffer>> [ alien-address ] bi@ < ;

PRIVATE>

TYPED: <arena> ( data: alien length: fixnum --  arena: arena )
    0 0 arena boa ;

TYPED:: alloc-align ( arena: arena size: fixnum align: fixnum -- alien )
    ! Get the relative offset
    align   arena nearest-align    :> new-ptr
    new-ptr arena offset-from-base :> offset

    arena offset size past-bounds?
    [ f ]
    [ arena offset >>prev-offset offset size + >>curr-offset drop
      new-ptr dup 0 size memset ]
    if ;

TYPED: alloc ( a: arena size: fixnum -- alien )
    default-alignment alloc-align ;

TYPED:: resize-align
    ( a: arena old-memory: alien old-size: fixnum new-size: fixnum align: fixnum
      -- alien )
    ! compute the old offset from the base
    old-memory a offset-from-base :> old-offset
    a prev-offset>> old-offset =  :> resize-current?
    { { [ old-memory f = old-size zero? or ]
        [ a new-size align alloc-align ] }
      ! here we check if it's below bounds and if it will be above
      ! bounds given the latest allocation
      { [ a [ old-memory below-bounds? ] [ old-offset new-size past-bounds? ] bi or ]
        [ f ] } ! make error value consistent with the other check
      { [ resize-current? ]
        [ new-size old-size >
          [ a current-address 0 new-size old-size - memset ] when
          new-size old-offset + a curr-offset<<
          old-memory ] }
      { [ t ]
        ! here we let the new memory fail, this can happen if we are
        ! allocating past the buffers end, either past the align or
        ! just with current + newsize
        [ a new-size align alloc-align dup ! new memory
          [ old-memory old-size new-size min memmove ] [  ] if ] } }
    cond ;

TYPED: resize ( a: arena old-memory: alien old-size: fixnum new-size: fixnum -- alien )
    default-alignment resize-align ;

: free ( arena ptr -- ) 2drop ; ! Free does nothing, as we don't rearrange

: free-all ( arena -- ) 0 >>curr-offset 0 >>prev-offset drop ; ! free the structure

! backs our memory allocator via a malloc
: arena-malloc ( size -- arena ) [ malloc ] keep <arena> ;

! frees a malloc backed arena
: arena-free-malloc ( arena -- ) buffer>> libc:free ;

! we could also back it via a mmap
