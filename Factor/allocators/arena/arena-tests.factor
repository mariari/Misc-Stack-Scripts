USING: assocs compiler.tree.debugger kernel tools.test
       typed kernel math unix.ffi locals
       alien alien.data alien.syntax
       make
       libc
       sequences
       namespaces
       accessors
       specialized-arrays.instances.alien.c-types.char
       allocators.arena allocators.arena.private allocators.utilities
    combinators ;
QUALIFIED-WITH: unix.ffi ffi
QUALIFIED-WITH: alien.c-types c

IN: allocators.arena.tests

: test-data ( -- data )
    ALIEN: 559d3628a044 1 M <arena> ;

{ 4 } [ 8 test-data buffer>> align-forward test-data offset-from-base ] unit-test

{ [ 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10
    0  0  0  0  0  10 10 10 10 10 10 10 10 10 10 10 ] }
[ 32 arena-malloc
  ! write over the entire region with 10's
  { [ 5 alloc 10 32 memset ]
    ! allocate a fresh region with 0's
    [ 5 alloc drop ]
    ! lets get the entire buffer
    [ buffer>> 32 c:char <c-direct-array> [ ] clone-like ]
    ! Free it after using it
    [ arena-free-malloc ]  } cleave ]
unit-test
