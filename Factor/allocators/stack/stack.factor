! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: typed kernel math namespaces accessors combinators allocators.utilities
       math.order
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
! ------------------------------------------------------------------------------
! Core Logic
! ------------------------------------------------------------------------------

:: calc-padding-wtih-header ( ptr align header-size -- padding )
    align ptr padding-needed-2^-checked :> padding
    header-size padding <=
    [ padding ]
    ! how much after padding is gone is the size needed
    [ header-size padding -         :> needed-space
      ! if the needed-space is not divisible by the align,
      ! then add 1 extra align of padding
      needed-space align mod-2^ sgn :> extra-padding
      padding align extra-padding needed-space align /i + * + ]
    if ;

TYPED:: alloc-align ( s: stack size: fixnum align: fixnum -- a: maybe{ alien } )
    ! we use 128 as the max alignment, as the header is a uint8_t
    s current-address align 128 min header-size calc-padding-wtih-header :> padding
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

TYPED:: free ( s: stack ptr: alien -- )
    { { [ ptr s within-bounds? not                       ] [ ] } ! can't free OOB
      { [ ptr s current-address [ alien-address ] bi@ >= ] [ ] } ! allow double free
      { [ t ]
        ! read the header from memory
        [ ptr dup read-header padding>> neg +-address s offset-from-base
          s offset<< ] }
    } cond ;

! ------------------------------------------------------------------------------
! Main API
! ------------------------------------------------------------------------------

TYPED: alloc ( s: stack size: fixnum -- a: maybe{ alien } )
    default-alignment alloc-align ;

: stack-malloc ( size -- stack ) [ malloc ] keep <stack> ;
: stack-free-malloc ( arena -- ) buffer>> libc:free ;
