! Generated words from Michelson → Factor

! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
QUALIFIED: math
IN: michelson.gen-vocab

! We'll likely have to use monads
! to track gas, and quit out early
! instead of using the monad library
! we'll just carry around the context as the first argument to all functions

TUPLE: context gas ;

! make a macro which calls a sub gas from contract
! and throws an error if this is violated
! also updating the comment to take a context and return it

! Michelson: abs 5 ( int -- nat ) math:abs ;

: abs ( int -- nat ) math:abs ;


! we do this instead of a variant
! note that we don't really need to generate a push
! really we need to update it to have a context as the last
! item, and move it to the first item in the output

GENERIC: push ( item type -- item )

SINGLETONS: +nat+ ;

M: +nat+ push drop ; inline
