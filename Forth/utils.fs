\ Helper functions I've made that aren't in a specific project

: copy-char ( addr-from addr-to -- )
  swap c@ swap c! ;

\ A worse cmove. is basically worse version of (cmove) below
: copy-string ( addr-from addr-to size -- )
  0 ?DO
    over i + over i + copy-char
  LOOP 2drop ;

\ From Jens Wilke
: (cmove)  ( c_from c_to u -- )
  bounds ?DO  dup c@ I c! 1+  LOOP  drop ;


( A dumb factorial implementation )
: factorial 1+ 1 tuck +do I * loop ;

( Recursive one of the same program )
: fact-priv dup 0 <= if drop else tuck * swap 1- recurse then ;
: fact      1 swap fact-priv ;

: fac1 ( n -- n! ) recursive
  dup 0> if dup 1- fac1 * else drop 1 endif ;

Variable pos

( from https://www.complang.tuwien.ac.at/anton/euroforth/ef03/pelc-oakford03.pdf )
( @pos is missing but I give a new meaning to it! )

' noop pos !

: @pos pos @ @ cell pos +! ;

: scope begin cr @pos 64 mod spaces ." *" key? until ;

( My weird version of scope )
: h@. @ hex . decimal ." :" ;

: mem-scope begin cr pos h@. @pos 64 mod 1+ spaces ." *" key? until ;
