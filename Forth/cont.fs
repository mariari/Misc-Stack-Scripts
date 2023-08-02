( basic continuation style program in forth  )

: exec ( w -- ? ) >r ;
: repeat-rest     r> dup >r exec ;
: bar  ( u -- u ) 1 + repeat-rest 2 + ;
: 2+   ( u -- u ) 2 + ;


( let us have fun now )

: ===>     ( c c -- ? ) over = if drop r> exec then rdrop ;
: either&  ( c -- )     [char] & ===> s" and" type ;
: interp   ( c -- )     either& ( else ) emit ;

( 0 bar )
( 0  ' 2+ exec )
( 38 interp )
( 39 interp )
