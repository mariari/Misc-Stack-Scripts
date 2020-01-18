: square  dup * ;

( LARGE LETTER-F)
: star  42 emit ;

: margin  cr  30 spaces ;

: blip  margin star ;

: stars 0 do star loop ;

: bar  margin 5 stars ;

: f bar blip bar blip blip cr ;


: 2b  4 * - 6 / + ;

: 2bd 8 2b ;

: quarters  4 /mod . ." ONES AND " . ." QUARTERS " ;

: non-factored over square swap * + ;
: factored over + * ;

: test 2dup ;

( Chapter 3 )

: ?if if ." IT'S FULL " then ;

: ?full 12 = if ." IT'S FULL " then ;

: ?Day 32 < if ." Looks Good " else ." no way " then ;

: Vegtable  dup 0< swap 10 mod 0= + if ." Artichoke " then ;

: ?Day  dup 1 < swap 31 > or
        if ." no way" else ." thank you" then ;

( solve ax² + bx + c )
: quadratic ( a b c x -- n)
  >r swap rot I dup * * swap r> * + + ;

( Chapter 5 )

: % 100 */ ;

( round up % if decimal greater than 0.5! )
: R% 10 */ 5 + 10 / ;

( πr² )
: π  square 24559 8192 */ ;

: test 10 0 do 2 loop ;

: decade 10 0 do I loop ;

: Table
  cr 11 1 do
    11 1 do I J *  5 u.r loop
    cr
  loop ;

( in normal definitions  )

( some fun!? )
: function-test ['] table  15 cells dump ;
: function-test-huh ['] table  execute ;
