! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test allocators.pool kernel combinators
       accessors alien.data allocators.pool math alien ;
IN: allocators.pool.tests

{ f }
[ 128 64 pool-malloc [ head-read next>> next>> ] [ pool-free-malloc ] bi ]
unit-test

{ f }
[ 128 64 pool-malloc
  { [ alloc drop ]
    [ alloc drop ]
    [ alloc ]
    [ pool-free-malloc ]
  } cleave ]
unit-test


{ t }
[ 128 64 + 64 pool-malloc
  { [ alloc dup ]
    [ alloc drop ]
    [ alloc drop ]
    ! free the first one
    [ swap free ]
    ! check the address are the same
    [ head>> = ]
    [ pool-free-malloc ]
  } cleave ]
unit-test

{ t t t t }
[let 128 64 + 64 pool-malloc :> pool
     pool alloc :> first-alloc
     pool alloc drop
     pool alloc :> third-alloc
     ! free the first one
     pool first-alloc free
     ! check the address are the same
     pool head>> first-alloc = :> first-test
     pool third-alloc free
     ! check again if it was added properly
     pool head>> third-alloc = :> second-test
     pool head-read next>> :> read
     ! check if the next node is the first node
     read >c-ptr first-alloc = :> third-test
     ! check if it's f after this, as we should be out of space
     read next>> f = :> fourth-test
     ! free the pool
     pool pool-free-malloc
     [ first-test second-test third-test fourth-test ] ]
unit-test
