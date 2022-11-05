! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: allocators.utilities
       math math.order namespaces accessors typed kernel combinators
       ranges sequences
       alien alien.data alien.syntax libc unix.ffi
       classes.struct alien.c-types ;
IN: allocators.pool

! From
! https://www.gingerbill.org/article/2019/02/16/memory-allocation-strategies-004/

! ------------------------------------------------------------------------------
! Data Type declarations
! ------------------------------------------------------------------------------

STRUCT: node
    { next node* } ;

TUPLE: pool
    { buffer        alien }
    { buffer-length fixnum }
    { chunk-size    fixnum }
    ! c types aren't real types, so Ι can't say it's a node*
    { head          maybe{ alien } initial: f }
    ! original buffer before alignment
    { buffer-orig   alien } ;

INSTANCE: pool bounds

DEFER: free-all
DEFER: pool-init

: <pool>-align ( buffer length chunk-size alignment -- pool )
    [ f BAD-ALIEN pool boa dup ] dip pool-init ;

: <pool> ( buffer length chunk-size -- pool )
    default-alignment <pool>-align ;

! how far the buffer has been displaced since the original allocation
! due to alignment
: buffer-displacement ( x -- x )
    [ buffer>> ] [ buffer-orig>> ] bi [ alien-address ] bi@ - ;

! ------------------------------------------------------------------------------
! Utility Functions
! ------------------------------------------------------------------------------

TYPED: head-read ( p: pool -- n: maybe{ node } )
    head>> dup f = [ drop f ] [ node deref ] if ;

: push-free-node ( pool node* -- )
    [ [ head>> ] dip node deref next<< ] [ >>head drop ] 2bi ;

: chunk-count ( pool -- count )
    [ buffer-length>> ] [ chunk-size>> ] bi /i ;
! ------------------------------------------------------------------------------
! Core Logic
! ------------------------------------------------------------------------------

:: pool-init ( pool alignment -- )
    pool [ buffer>> ] [ buffer-orig<< ] bi
    pool
    [ alien-address alignment align <alien> ] change-buffer ! align the pool
    [ pool buffer-displacement -            ] change-buffer-length
    [ alignment align                       ] change-chunk-size

    [ chunk-size>> node heap-size >= t assert= ]
    [ [ buffer-length>> ] [ chunk-size>> ] bi >= t assert= ]
    [ free-all ]
    tri ;

! ------------------------------------------------------------------------------
! Backing the Arena
! ------------------------------------------------------------------------------

: pool-malloc ( size chunk-size -- pool )
    [ [ malloc ] keep ] dip <pool> ;

: pool-free-malloc ( pool -- )
    buffer>> libc:free ;

! ------------------------------------------------------------------------------
! Main API
! ------------------------------------------------------------------------------
TYPED:: alloc ( p: pool -- a: maybe{ alien } )
    p head-read
    [ [ next>> >c-ptr p head<< ] [ >c-ptr 0 p chunk-size>> memset ] [ >c-ptr ] tri ]
    [ f ]
    if* ;

! double frees are an issue, to check for them it would take O(n)
! time, we really should add this as a check
TYPED: free ( p: pool ptr: alien --  )
    { { [ dup not ]                      [ 2drop ] }
      { [ 2dup swap within-bounds? not ] [ 2drop ] }
      { [ t ]                            [ push-free-node ] }
    } cond ;

TYPED:: free-all ( p: pool -- )
    p chunk-count [0..b)
    [ p [ chunk-size>> * ] [ buffer>> swap +-address ] [ swap push-free-node ] tri ]
    each ;
