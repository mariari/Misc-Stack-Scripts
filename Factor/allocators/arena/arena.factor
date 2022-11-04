! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: typed kernel math namespaces accessors combinators math.order
       alien alien.data alien.syntax libc unix.ffi allocators.utilities ;
QUALIFIED-WITH: alien.c-types c

IN: allocators.arena

! Taken from
! https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/

! ------------------------------------------------------------------------------
! Data Type declarations
! ------------------------------------------------------------------------------

TUPLE: arena
    { buffer        alien }
    { buffer-length fixnum }
    { prev-offset   fixnum initial: 0 }
    { curr-offset   fixnum initial: 0 } ;

INSTANCE: arena bounds

TYPED: <arena> ( data: alien length: fixnum --  arena: arena )
    0 0 arena boa ;

TUPLE: save-point
    { arena arena }
    { prev-offset   fixnum initial: 0 }
    { curr-offset   fixnum initial: 0 } ;

TYPED: <save-point> ( a: arena -- s: save-point )
    dup [ prev-offset>> ] [ curr-offset>> ] bi save-point boa ;


TYPED: current-address ( arena: arena -- current: alien )
    [ buffer>> alien-address ] [ curr-offset>> ] bi + <alien> ;

! ------------------------------------------------------------------------------
! Utility Functions
! ------------------------------------------------------------------------------

<PRIVATE

TYPED: align-forward ( align: fixnum ptr: alien -- aligned-ptr: alien )
    alien-address swap assert-2^ align <alien> ;

TYPED: nearest-align ( align arena -- address: alien )
    current-address align-forward ;

PRIVATE>

! ------------------------------------------------------------------------------
! Core Logic
! ------------------------------------------------------------------------------

TYPED:: alloc-align ( arena: arena size: fixnum align: fixnum -- a: maybe{ alien } )
    ! Get the relative offset
    align   arena nearest-align    :> new-ptr
    new-ptr arena offset-from-base :> offset

    new-ptr size +-address arena past-bounds?
    [ f ]
    [ arena offset >>prev-offset offset size + >>curr-offset drop
      new-ptr dup 0 size memset ]
    if ;

TYPED:: resize-align
    ( a: arena old-memory: alien old-size: fixnum new-size: fixnum align: fixnum
      -- a: maybe{ alien } )
    ! compute the old offset from the base
    old-memory a offset-from-base :> old-offset
    a prev-offset>> old-offset =  :> resize-current?
    { { [ old-memory f = old-size zero? or ]
        [ a new-size align alloc-align ] }
      { [ old-memory new-size +-address a past-bounds?
          old-memory                    a below-bounds?
          or ]
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
          [ old-memory old-size new-size min memmove ] [  ] if ] }
    } cond ;

! ------------------------------------------------------------------------------
! Backing the Arena
! ------------------------------------------------------------------------------

: arena-malloc ( size -- arena ) [ malloc ] keep <arena> ;

: arena-free-malloc ( arena -- ) buffer>> libc:free ;

! we could also back it via a mmap, but Ι will leave this as an
! exercise to the reader

! ------------------------------------------------------------------------------
! Main API
! ------------------------------------------------------------------------------

TYPED: alloc ( a: arena size: fixnum -- a: maybe{ alien } )
    default-alignment alloc-align ;

TYPED: resize ( a: arena old-memory: alien old-size: fixnum new-size: fixnum -- alien )
    default-alignment resize-align ;

: free ( arena ptr -- ) 2drop ;

: free-all ( arena -- ) 0 >>curr-offset 0 >>prev-offset drop ;

ALIAS: snapshot <save-point>

TYPED: restore ( s: save-point -- )
    dup arena>>
    [ [ curr-offset>> ] dip curr-offset<< ]
    [ [ prev-offset>> ] dip prev-offset<< ] 2bi ;
