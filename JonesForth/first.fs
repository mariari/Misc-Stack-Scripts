: LAST-SIZE ( -- size )
  HERE @ LATEST @ - ;

: DUMP-LAST-CONTENTS ( -- )
  LATEST @ LAST-SIZE DUMP ;

\ DUMP-LAST-CONTENTS
\  8FAADA0 74 AD FA  8 12 44 55 4D 50 2D 4C 41 53 54 2D 43 t....DUMP-LAST-C
\  8FAADB0 4F 4E 54 45 4E 54 53  0 A3 90  4  8 68 A7  4  8 ONTENTS.....h...
\  8FAADC0 F4 A3  4  8 84 AD FA  8 CC 9C FA  8 50 A0  4  8 ............P...

\ We can't use ['] for a dynamic word coming in, but we can get some addresses
: GET-CFA ( "word" -- c ) WORD FIND >CFA ;

\ example usage
\ VARIABLE HI
\ GET-CFA HI HEX . DECIMAL CR \ dump the CFA address
