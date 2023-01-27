! Copyright (C) 2023 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: vocabs.parser words kernel math compiler.units ;
IN: misc.create-function


[ "my-square-testtest" current-vocab create-word [ dup * ] ( x -- x^2 ) define-declared ]
with-compilation-unit
