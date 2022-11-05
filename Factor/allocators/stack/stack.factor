! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: allocators.utilities
       math math.order namespaces accessors typed kernel combinators
       alien alien.data alien.syntax libc unix.ffi classes.struct alien.c-types ;
IN: allocators.stack

! From
! https://www.gingerbill.org/article/2019/02/15/memory-allocation-strategies-003/

! ------------------------------------------------------------------------------
! Data Type declarations
! ------------------------------------------------------------------------------

TUPLE: stack
    { buffer alien }
    { buffer-length fixnum }
    { offset fixnum } ;

INSTANCE: stack bounds

STRUCT: header
   { padding uint8_t } ;

TYPED: <stack> ( buffer: alien length: fixnum -- s: stack )
    0 stack boa ;

: <header> ( padding -- header )
    header boa ;

! ------------------------------------------------------------------------------
! Utility
! ------------------------------------------------------------------------------

TYPED: current-address ( s: stack -- c: alien )
    [ buffer>> alien-address ] [ offset>> ] bi + <alien> ;

: header-size ( -- fixnum ) header heap-size ;

! determine where the header offset is from a given address
: header-offset ( -- -header-size ) header-size neg ;

! Read the header directly from a given address
TYPED: read-header-directly ( address: alien -- h: header )
    header deref ;

! Read the header given the stack memory allocation address
TYPED: read-header ( address: alien -- h: header )
    header-offset +-address read-header-directly ;

<PRIVATE

! checks for data that has already been double freed
TYPED: double-free? ( ptr: alien s: stack -- free?: boolean )
    current-address [ alien-address ] bi@ >= ;

TYPED: address-before-allocation ( x: alien -- x: alien )
    dup read-header padding>> neg +-address ;

PRIVATE>

! ------------------------------------------------------------------------------
! Core Logic
! ------------------------------------------------------------------------------

:: calc-padding-with-header ( ptr algn header-size -- padding )
    algn ptr padding-needed-2^-checked :> padding
    header-size padding <=
    [ padding ]
    ! promote the header-size to the nearest alignment then add back the padding
    [ header-size padding - algn align padding + ]
    if ;

TYPED:: alloc-align ( s: stack size: fixnum align: fixnum -- a: maybe{ alien } )
    ! we use 128 as the max alignment, as the header is a uint8_t
    s current-address align 128 min header-size calc-padding-with-header :> padding
    ! check if we are out of memory
    s [ offset>> padding size + + ] [ buffer-length>> ] bi >
    [ f ]
    [ s current-address padding +-address :> next-addr
      ! setting the padding before the allocated space to the expected value
      padding next-addr read-header padding<<

      ! Set the offset, which we've added the padding and the size to
      ! the current offset
      size padding s offset>> + + s offset<<
      next-addr [ 0 size memset ] keep ]
    if ;

TYPED: unsafe-free ( s: stack ptr: alien -- )
    address-before-allocation swap [ offset-from-base ] [ offset<< ] bi ;

TYPED:: resize-align
    ( s: stack ptr: alien old-size: fixnum new-size: fixnum align: fixnum
      -- s: maybe{ alien } )
    { { [ ptr not        ]           [ f ] }
      { [ ptr s within-bounds? not ] [ f ] } ! Can't resize OOB
      { [ ptr s double-free?       ] [ f ] }
      { [ new-size zero? ]           [ s ptr unsafe-free f ] }
      { [ old-size new-size =      ] [ ptr ] }
      { [ t ]
        [ s new-size align alloc-align dup [ ptr new-size memmove ] [ ] if ] }
    } cond ;

! ------------------------------------------------------------------------------
! Backing the Arena
! ------------------------------------------------------------------------------

: stack-malloc ( size -- stack ) [ malloc ] keep <stack> ;
: stack-free-malloc ( stack -- ) buffer>> libc:free ;

! ------------------------------------------------------------------------------
! Main API
! ------------------------------------------------------------------------------

TYPED: alloc ( s: stack size: fixnum -- a: maybe{ alien } )
    default-alignment alloc-align ;

TYPED: resize ( a: stack ptr: alien old-size: fixnum new-size: fixnum -- stack )
    default-alignment resize-align ;

TYPED: free ( s: stack ptr: alien -- )
    { { [ 2dup swap within-bounds? not ] [ 2drop ] } ! can't free OOB
      { [ 2dup swap double-free?       ] [ 2drop ] } ! allow double free
      { [ t                            ] [ unsafe-free ] }
    } cond ;

TYPED: free-all ( s: stack -- )
    0 swap offset<< ;
