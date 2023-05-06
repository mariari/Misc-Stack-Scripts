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
