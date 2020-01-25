
USING: io memoize macros math namespaces kernel lists lists.lazy sequences fry ;

IN: first

MEMO: test ( a  -- bool ) 4 = ;

: foo ( x -- x ) 4 = ;

: nip ( x x -- x ) = ;

: bar ( x x -- x ) = ;

: baz ( x x -- x ) bar ;

: copy-op ( x y -- x x y ) swap dup rot ;

: test-filter ( -- x x ) 3 { -12 10 16 0 -1 -3 -9 } [ copy-op < ] filter ;

: test-filter' ( -- x x ) 3 { -12 10 16 0 -1 -3 -9 } [ swap dup  rot < ] filter ;


<PRIVATE
! Helpers for quicksort

! operation
: sfilter ( number list operation -- filtered number )
    ! For some reason compiled call's have to do this
    ! number operation number operation car -> number operation number car operation
    swap [ [ 2dup ] dip swap call( x x -- x ) ] filter swap drop swap ; inline

: on-car ( x quote  -- ? )
    [ car ] dip  call( x --  ? ) ;

! if we don't inline we have to say call( x -- ? )
! in fact if we use the above form, the output is much less optimized
! swap [ car swap call( x -- ? ) ] keep cons ;
: run-on-car ( x quote  -- ? )
    [ dup car ] dip call swap cons ; inline

PRIVATE>

! evolution of quick sort
! ----------------------------------------------------

: quicksort' ( x -- x )
    [ { } ]
    [ dup dup dup 0 swap nth swap
      [ copy-op > ] filter quicksort'
      swap rot [ copy-op = ] filter
      rot swap append
      swap rot [ copy-op < ] filter quicksort'
      rot swap append
      swap drop
    ]
    if-empty ;

: quicksort'' ( xs -- xs )
    [ { } ]
    [ [ first ] keep
      [ [ > ] sfilter [ quicksort'' ] dip ]
      [ [ = ] sfilter ]
      [ [ < ] sfilter [ quicksort'' ] dip ] tri
      drop append append ]
    if-empty ;

: quicksort ( xs -- xs )
    [ { } ]
    [ [ first ] keep swap
      [ '[ _ < ] filter quicksort ]
      [ '[ _ = ] filter ]
      [ '[ _ > ] filter quicksort ] 2tri
      append append ]
    if-empty ;

! these are the same!
! [ [ = ] curry lfilter ]

: list.quicksort ( xs -- xs )
    dup nil?
    [  ]
    [ [ car ] keep swap
      [ '[ _ < ] lfilter list.quicksort ]
      [ '[ _ = ] lfilter ]
      [ '[ _ > ] lfilter list.quicksort ] 2tri
      lappend-lazy lappend-lazy ]
    if ;

! ----------------------------------------------------

: list-filter ( ... list quot: ( ... elt -- ... ? ) -- ... sub-list )
    over nil?
    [ drop ]
    [ 2dup
      on-car
      [ [ cdr ] dip list-filter ]
      [ over car rot cdr rot list-filter cons ]
      if ]
    if ;

! { 1 2 3 4 5 1 123 123 12 31 231 1 2 3 4 5 1 123 123 12 31 231 1 2 3 4 5 1 123 123 12 31 231 1 2 3 4 5 1 123 123 12 31 231 } [ quicksort ] time

! { 1 2 3 4 5 1 123 123 12 31 231 1 2 3 4 5 1 123 123 12 31 231 1 2 3 4 5 1 123 123 12 31 231 1 2 3 4 5 1 123 123 12 31 231 } sequence>list [ list.quicksort ] time [ list>array ] time
