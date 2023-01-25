! Copyright (C) 2021 .
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences math.order literals ;
QUALIFIED-WITH: namespaces name
IN: tax

<<

: percent ( taxes-paid income -- percent ) / ;

! a complicated way to say /
! [ swap - ] keep / 1 swap - ;

: simple ( tax income -- final ) * ;

! ------------------------------------------------------------------
! Conversion rate is stored as a global variable as it is simpler to
! reason about when it is fixed, yet moldable
! ------------------------------------------------------------------

SYMBOL: conversion

conversion [ 0.03329 ] name:initialize

: conversion-rate ( -- rate )
    conversion name:get-global ;

: set-ntd-to-usd ( new-rate -- )
    conversion name:set-global ;

: usd-to-ntd ( money -- money )
    conversion-rate / ;

: ntd-to-usd ( money -- money )
    conversion-rate * ;

<PRIVATE

: taiwan-table ( --  table )
    { { 0       540000  0.05 }
      { 540000  1210000 0.12 }
      { 1210000 2420000 0.20 }
      { 2420000 4530000 0.30 }
      { 4530000 1/0.    0.40 }
    } ;

: taiwan-table-gold ( --  table )
    { { 0       540000  0.05 }
      { 540000  1210000 0.12 }
      { 1210000 2420000 0.20 }
      { 2420000 3000000 0.30 }
      { 3000000 4530000 0.15 }
      { 4530000 1/0.    0.20 }
    } ;

: bracket-range ( sequence -- n ) first2 swap - ;

: tax-paid-in-bracket ( salary table -- untaxed-salary-left tax )
    [ bracket-range [-] ]                  ! setup salary left
    [ [ bracket-range min ] keep third * ] ! setup tax information
    2bi ;

: with-usd-to-ntd ( money op -- money )
    [ usd-to-ntd ] dip call( a -- a ) ntd-to-usd ;

PRIVATE>

: taxes-owed-ntd ( income-ntd -- taxes-paid )
    taiwan-table-gold [ tax-paid-in-bracket ] map-sum nip ;

: taxes-owed ( income-usd -- taxes-paid-usd )
    [ taxes-owed-ntd ] with-usd-to-ntd ;

: income-after-taxes ( income -- left )
    [ taxes-owed ] keep swap - ;

: health-care ( income -- cost )
    0.0517 * ;

: calculate-yearly ( monthly-value operation -- monthly-return )
    [ 12 * ] dip call( a -- a ) 12 / ;

>>

: drinks ( --  NTD ) 120 ;

: food ( -- amount-NTD ) 2 500 * ;

: train-tickets ( -- NTD ) 50 ;

: cell ( -- NTD ) 620 ;

: internet ( -- NTD ) 1136 ;

: haircut  ( -- NTD ) 570 ;

: private-health-insurance ( -- NTD ) 250 usd-to-ntd ;

: electricity ( -- NTD ) 1200 ;

: monthly-expenses  ( -- amount-in-NTD )
    0
    ${ drinks train-tickets food }         [ + ] each 30 *
    ${ cell internet haircut electricity } [ + ] each ;

: calculate-expenses ( rent income-per-month -- left-each-month )
    [ dup
      [ taxes-owed - ]       ! taxes
      [ 0.10  * - ]          ! savings
      [ health-care - ]      ! public healthcare costs
      tri
    ] calculate-yearly
    swap -                   ! rent
    monthly-expenses ntd-to-usd - ;
