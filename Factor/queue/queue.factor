! Copyright (C) 2020 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: variants kernel math ;
IN: queue


VARIANT: list
    nil
    cons: { { car object } { cdr list } } ;

! so <cons> is the constructor


: list-length ( list -- length )
    { { nil  [ 0 ] }
      { cons [ nip list-length 1 + ] }
    } match ;

! why is ours so oddly fast!


! 1 2 3 4 5 6 7 8 9 10 nil <cons> <cons> <cons> <cons> <cons> <cons> <cons> <cons> <cons> <cons> [ list-length ] time
! Running time: 4.834e-06 seconds

! IN: scratchpad dup [ list-length ] time .
! Running time: 8.633e-06 seconds

! this is slower than our list now!
! IN: scratchpad [ 1 2 3 4 5 6 7 8 9 10 ] [ length ] time .
! Running time: 1.7314e-05 seconds


! IN: scratchpad 1 2 3 4 5 6 7 8 9 10 nil cons cons cons cons cons cons cons cons cons cons [ llength ] time .
! Running time: 7.375e-06 seconds


! IN: scratchpad [ 1 2 3 4 5 6 7 8 9 10 ] >vector [ length ] time
! Running time: 2.8503e-05 seconds
