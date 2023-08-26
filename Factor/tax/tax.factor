! Copyright (C) 2021 .
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences math.order
literals prettyprint.custom accessors classes combinators ;
QUALIFIED-WITH: namespaces name
IN: tax

<<

! Currency declarations
TUPLE: taiwan  { amount number } ;
TUPLE: america { amount number } ;

! Generic Currency Conversion Words
GENERIC#: denominate 1 ( amount denomination -- dnominated-amount )
GENERIC: conversion ( currency -- rate )

: set-denom ( u curr -- denom ) new swap >>amount ;
: >base     ( denom -- base )   [ conversion ] [ amount>> ] bi * ;
: from-base ( u curr -- denom ) [ name:get / ] [ set-denom ] bi ;

M: number denominate set-denom ;
M: tuple  denominate
    swap 2dup class-of = [ nip ] [ >base swap from-base ] if ;

! Creating Currencies
: NTD ( u -- u ) taiwan denominate ;
: TWD ( u -- u ) NTD ;
: 元 ( u -- u ) NTD ;
: 萬 ( u -- u ) 元 [ 10,000 * ] change-amount ;

: USD ( u -- u ) america denominate ;

<PRIVATE

! Operating Generic Math
:: apply ( x y fn -- z )
    x clone [ y fn call( x y -- z ) ] change-amount ;
:: apply-op ( x y fn -- z )
    y clone [ x swap fn call( x y -- z ) ] change-amount ;

:: op-both ( x y fn -- z )
    { { [ x y [ tuple? ] both? x y [ class-of ] same? and ]
        [ x y amount>> fn apply ] }
      { [ x y [ tuple? ] both? ] [ x y x class-of denominate fn op-both ] }
      { [ x tuple? ] [ x y fn apply ] }
      { [ y tuple? ] [ x y fn apply-op ] }
      [ x y fn call( x y -- z ) ]
    } cond ;

:: op-one ( x y fn -- z )
    x tuple? y tuple? and
    [ "Can't apply operation on 2 currencies" throw ] [ x y fn op-both ] if ;

: pprint-NTD ( amount -- )
    10,000.0 2dup >=
    [ / pprint* \ 萬 pprint* ] [ drop pprint* \ 元 pprint* ] if ;

PRIVATE>

: C+ ( x y -- z ) [ + ] op-both ;
: C- ( x y -- z ) [ - ] op-both ;
: C* ( x y -- z ) [ * ] op-one ;
: C/ ( x y -- z ) [ / ] op-one ;

M: taiwan  pprint* amount>> pprint-NTD ;
M: america pprint* amount>> pprint* \ USD pprint* ;

! ------------------------------------------------------------------
! Conversion rate is stored as a global on the class symbol
! ------------------------------------------------------------------

taiwan  [ 0.03329 ] name:initialize
america [ 1       ] name:initialize

: set-ntd ( new-rate -- ) taiwan name:set-global ;

M: taiwan  conversion drop taiwan name:get-global ;
M: america conversion drop 1 ;

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

: owe ( salary bracket -- x )
    [ first [-] ] [ bracket-range min ] [ third * ] tri ;

PRIVATE>

: taxes ( ntd -- paid )
    元 amount>> taiwan-table [ dupd owe ] map-sum nip 元 ;

: after-taxes ( usd -- left ) [ taxes ] keep swap - ;

: health-care ( income -- cost ) 0.0517 C* ; ! unconfirmed

: savings ( income -- cost ) 0.10 C* ;

: yearly ( monthly-value operation -- monthly-return )
    [ 12 C* ] dip call( a -- a ) 12 C/ ;

>>

: metro       ( -- NTD ) 50 元 ;
: drinks      ( -- NTD ) 120 元 ;
: food        ( -- NTD ) 500 元 2 C* ;

: cell        ( -- NTD ) 650  元 ;
: internet    ( -- NTD ) 1136 元 ;
: haircut     ( -- NTD ) 570  元 ;
: electricity ( -- NTD ) 1200 元 ;

: private-health-insurance ( -- NTD ) 250 USD ;

: daily   ( -- NTD ) 0 ${ drinks food metro } [ C+ ] each ;
: monthly ( -- NTD ) 0 ${ cell internet haircut electricity } [ C+ ] each ;

: dynamic  ( monthly -- $ ) [ [ savings ] [ taxes C+ ] bi ] yearly ;
: static   ( -- $ )              daily 30 C* monthly C+ ;
: expenses ( rent monthly -- $ ) dynamic C+ static C+ ;

: after-expenses ( rent monthly -- left )
    [ expenses ] keep swap C- ;
