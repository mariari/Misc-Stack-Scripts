IN: compiling-lisp.unary
USING: typed kernel alien.syntax math unix.ffi locals  alien ;
QUALIFIED-WITH: unix.ffi ffi
QUALIFIED-WITH: alien.c-types c

: foo ( -- x ) 3 math:?1+ ;

: base ( -- address: c:void* ) 0x10000000 <alien> ;

: K ( -- size: c:ulonglong ) 1024 ;
: M ( -- size: c:ulonglong ) 1048576 ;
: G ( size: c:ulonglong -- size: c:ulonglong ) 1073741824 * ;

CONSTANT: MAP_ANONYMOUS 0x20
CONSTANT: MAP_FIXED     0x10

:: allocate ( size: c:size_t -- memory: c:void* )
    ! f can be used for a null pointer
    base size
    PROT_READ PROT_WRITE +
    MAP_PRIVATE MAP_ANONYMOUS +
    -1 0
    mmap ;

: deallocate ( memory: c:void* size: c:size_t -- c:int )
    munmap ;
