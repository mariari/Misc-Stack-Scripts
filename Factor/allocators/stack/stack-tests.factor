! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test allocators.stack
       allocators.utilities accessors combinators math kernel ;
IN: allocators.stack.tests


{ 14 } [ 0x1236122 8  8 calc-padding-wtih-header ] unit-test
{ 14 } [ 0x1236122 16 8 calc-padding-wtih-header ] unit-test
{ 32 } [ 0x1236128 8 32 calc-padding-wtih-header ] unit-test

{ 64 }
[ 1 M stack-malloc
  { [ 64 16 - alloc drop ]
    ! we want to reset to having 64 bytes reserved
    [ 100 alloc ]
    [ 100 alloc drop ]
    ! free the reserved spot
    [ swap free ]
    ! let us return the value
    [ offset>> ]
    [ stack-free-malloc ]
  } cleave ]
unit-test
