( Code mostly stolen )

: mid    ( ul ur -- u )   over - 2/ + ;
: radius ( ad1 ad2 -- u ) - 2/ abs ;
: adswap ( ad1 ad2 -- )   over @ over @ swap rot ! swap ! ;

: singlepart ( ad1 ad2 -- ad )
  tuck 2dup @ locals| p ad | swap                \ ad2 ad2 ad1
  do i @ p <                                     \ ad2 flag
     if ad i adswap ad cell + to ad then cell    \ ad2 cell
  +loop ad adswap ad ;                           \ ad

: qsort ( ad1 ad2 -- ) \    pointing on first and last cell in array
  begin
    2dup < 0= if 2drop exit then
    2dup radius >r \ keep radius (half of the distance)
    2dup singlepart 2dup - >r >r \ ( R: radius distance2 ad )
    r@ cell - swap r> cell+ swap \ ( d-subarray1 d-subarray2 )
    2r> u< if 2swap then recurse \ take smallest subarray first
  again ; \ tail call optimization by hand

: sort ( array len -- ) 1- cells over + qsort ;


0 Value fd-in
0 Value fd-out
: open-input ( addr u -- )  r/o open-file throw to fd-in ;
: open-output ( addr u -- )  w/o create-file throw to fd-out ;

( Parsing a String  32 $split 32 skip )
( For day 1 this doesn't matter )
