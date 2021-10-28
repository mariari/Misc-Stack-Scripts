! Copyright (C) 2021 .
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences math.order literals ;
IN: tax

: percent ( taxes-paid income -- percent ) / ;

! a complicated way to say /
! [ swap - ] keep / 1 swap - ;

: simple ( tax income -- final ) * ;

<PRIVATE

: taiwan-table ( --  table )
    { { 0       540000  0.05 }
      { 540000  1210000 0.12 }
      { 1210000 2420000 0.20 }
      { 2420000 4530000 0.30 }
      { 4530000 1/0.    0.40 }
    } ;

: bracket-range ( sequence -- n ) first2 swap - ;

: tax-paid-in-bracket ( salary table -- untaxed-salary-left tax )
    [ bracket-range [-] ]                  ! setup salary left
    [ [ bracket-range min ] keep third * ] ! setup tax information
    2bi ;

: convert-currency-for ( conversion money op -- money )
    [ over / ] dip call( a -- a ) * ;

PRIVATE>

: proper-ntd ( income -- taxes-paid )
    taiwan-table [ tax-paid-in-bracket ] map-sum nip ;

: proper ( conversion income -- taxes-paid )
    [ proper-ntd ] convert-currency-for ;

: income-after-taxes ( conversion income -- left )
    [ proper ] keep swap - ;

: health-care ( income -- cost )
    0.0517 * ;

: calculate-yearly ( monthly-value operation -- monthly-return )
    [ 12 * ] dip call( a -- a ) 12 / ;

: calculate-expenses ( rent income-per-month -- left-each-month )
    [ dup
      [ 0.035 swap proper - ] ! taxes
      [ 0.10  * - ]           ! savings
      [ health-care - ]       ! public healthcare costs
      tri
    ] calculate-yearly
    swap -                   ! rent
    ${ 2 30    *             ! train tickets
       2 15 30 * *           ! food
       250                   ! private health insurance
       70                    ! electricity
       25                    ! internet
       25                    ! cell
    } [ - ] each ;
