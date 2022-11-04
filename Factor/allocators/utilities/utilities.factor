! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math typed syntax alien alien.c-types accessors ;
IN: allocators.utilities

! Why do we 2 times the size of void*?
: default-alignment ( -- alignment ) void* heap-size 2 * ;

: 2^? ( address -- aligned? )
    dup 1 - bitand zero? ;

: assert-2^ ( address -- address )
    dup 2^? t assert= ;

! same as ptr align mod but bitand is faster if align is a power of 2
: mod-2^ ( value power -- modded-value )
    1 - bitand ; inline

: K ( number -- KBs ) 1024 * ;
: M ( number -- MBs ) 1048576 * ;
: G ( number -- GBs ) 1073741824 * ;

! 2^ is just an optimized version
GENERIC: padding-needed    ( align       address -- padding-needed )
GENERIC: padding-needed-2^ ( align-pow-2 address -- padding-needed )

M: number padding-needed
    over mod [ drop 0 ] [ - ] if-zero ;
M: alien  padding-needed
    alien-address padding-needed ;

M: number padding-needed-2^
    over mod-2^ [ drop 0 ] [ - ] if-zero ;
M: alien  padding-needed-2^
    alien-address padding-needed-2^ ;

: padding-needed-2^-checked ( align-pow-2 address -- padding-needed )
   [ assert-2^ ] dip padding-needed-2^ ;

MIXIN: bounds

SLOT: buffer
SLOT: buffer-length

GENERIC: past-bounds?     ( address bounds -- past? )
GENERIC: below-bounds?    ( address bounds -- below? )
GENERIC: offset-from-base ( address bounds -- offset-from-base )

M: bounds offset-from-base
    buffer>> [ alien-address ] bi@ - ;

M: bounds past-bounds?
    [ offset-from-base ] keep buffer-length>> > ;

M: bounds below-bounds?
    buffer>> [ alien-address ] bi@ < ;

TYPED: within-bounds? ( address: alien b: bounds -- b: boolean )
    [ past-bounds? ] [ below-bounds? ] 2bi or not ;

TYPED: +-address ( a: alien f: fixnum -- a+f: alien )
    [ alien-address ] dip + <alien> ;
