! Copyright (C) 2020 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: variants kernel math ;
IN: finger-tree


VARIANT: Digit
    One: { one }
    Two: { one two }
    Three: { one two three }
    Four: { one two three four }
    ;

! so <cons> is the constructor

! these two forms are basically doing ID on it
: test ( digit -- digit )
    { { One [ One boa ] }
      { Two [ <Two> ] }
    } match ;
