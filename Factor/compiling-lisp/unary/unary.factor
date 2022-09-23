IN: compiling-lisp.unary
USING: typed kernel alien.syntax math unix.ffi locals
       alien alien.data
       cpu.x86.assembler
       cpu.x86.assembler.operands
       make
       libc
       sequences ;
QUALIFIED-WITH: unix.ffi ffi
QUALIFIED-WITH: alien.c-types c

! Missing Constants
CONSTANT: MAP_ANONYMOUS 0x20
CONSTANT: MAP_FIXED     0x10

! Missing FFI Functions
LIBRARY: libc
FUNCTION: c:int mprotect ( c:void* addr, c:size_t len, c:int prot )

! Address to allocate an offset from.
: base ( -- address: c:void* ) 0x10000000 <alien> ;

: K ( size: c:ulonglong -- size: c:ulonglong ) 1024 * ;
: M ( size: c:ulonglong -- size: c:ulonglong ) 1048576 * ;
: G ( size: c:ulonglong -- size: c:ulonglong ) 1073741824 * ;

! Allocation Functionality
:: allocate ( size: c:size_t -- memory: c:void* )
    ! f can be used for a null pointer
    base size
    PROT_READ PROT_WRITE bitor
    MAP_PRIVATE MAP_ANONYMOUS bitor
    -1 0
    mmap ;

: deallocate ( memory: c:void* size: c:size_t -- c:int ) munmap ;

! This thanks to the RET allows us to just allocate and run it
: program ( -- array )
    [ EAX 42 MOV
      0 RET
    ] { } make ;

! Function type

TYPED: program-ptr ( -- uint-array: c-ptr )
    program c:uchar >c-array >c-ptr ;

: program-length ( -- int ) program-ptr length ;

TYPED: allocate-program ( -- memory: c-ptr )
    1 M allocate dup
    [ program-ptr program-length memcpy ]
    ! PROT_EXEC is to execute memory
    [ program-length PROT_EXEC PROT_READ + mprotect
      0 assert= ]
    bi ;

: invoke-memory-function ( ptr: c-ptr -- result: c:int )
    c:int [ ] cdecl alien-indirect ;

: run-program ( -- res )
    allocate-program
    [ invoke-memory-function ] [ 1 M deallocate drop ] bi ;

! Transcribed from C
! Keeping here for learning/legacy reasons
! Overall just a worse run-program
: run-program% ( -- res )
    [let 1 M allocate                   :> memory
         program c:uint >c-array >c-ptr :> program
         program length                 :> prog-len

     memory program-ptr prog-len memcpy
     ! we are just doing this to execute memory
     memory prog-len PROT_EXEC mprotect drop

     memory invoke-memory-function :> res

     memory 1 M deallocate drop

     res
    ] ;
