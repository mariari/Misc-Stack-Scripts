! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces alien.data unix.ffi alien typed libc ;
IN: allocators.arena-global

QUALIFIED-WITH: alien.c-types c

: M ( size: c:ulonglong -- size: c:ulonglong ) 1048576 * ;

! Taken from
! https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/

! --------------------------------------------------------------------------------
! Basic Bad allocator see arena.factor instead of this one
! --------------------------------------------------------------------------------

SYMBOL: arena-buffer
SYMBOL: arena-buffer-length
SYMBOL: arena-offset

arena-offset [ 0 ] initialize

arena-buffer-length [ 1 M ] initialize

arena-buffer [ arena-buffer-length get c:char malloc-array ] initialize

:: index-address ( c-type index address -- address )
    c-type c:heap-size index * address <displaced-alien> ;

TYPED:: global-arena-alloc ( size: fixnum --  ptr )
    arena-buffer get >c-ptr :> address
    arena-offset get        :> offset
    arena-buffer-length get :> arena-length
    size offset + arena-length <=
    [ size arena-offset +@
      ! Zero out the memory location by default
      c:char offset address index-address
      dup 0 size memset
    ]
    ! return f if the arena is out of memory
    [ f ]
    if ;
