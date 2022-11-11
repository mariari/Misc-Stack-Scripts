! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.struct alien.c-types math ;
IN: misc.padding

! Reading https://www.catb.org/esr/structure-packing/

STRUCT: foo3
    { s short }
    { c char* } ;

STRUCT: foo2
    { c char }
    { s foo3 } ;

! same size as each other

STRUCT: char-short
    { c char }
    { s short } ;

STRUCT: char-short-no-padding
    { c1 char }
    { c2 char }
    { s short } ;

STRUCT: list-wasteful
    { c char }           ! 1 byte,  7 bytes padding
    { p list-wasteful* } ! 8 bytes, 0 bytes padding
    { x short } ;        ! 2 bytes, 6 bytes padding

! going biggest to smallest works!

STRUCT: list
    { p list* }
    ! swapping these last two don't matter as the ending padding eats up
    { x short }
    { c char } ;

! going smallest to biggest also works

STRUCT: list-also-works
    ! swapping these last two don't matter as the ending padding eats up
    { c char }
    { x short }
    { p list* } ;

! best to keep data in a cache line or for readability

! on a 64 bit machine, 64 bytes is the cache line

! cache locality matters more than slight savings

! arrange so reads come in from one cache line and go to the next

TUPLE: foo-tuple { c fixnum } { c2 fixnum } ;
