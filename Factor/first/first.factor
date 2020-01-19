
USING: io memoize macros math namespaces kernel lists lists.lazy sequences ;

IN: first

MEMO: test ( a  -- bool ) 4 = ;

: foo ( x -- x ) 4 = ;

: nip ( x x -- x ) = ;

: bar ( x x -- x ) = ;

: baz ( x x -- x ) bar ;

: copy-op ( x y -- x x y ) swap dup rot ;

: test-filter ( -- x x ) 3 { -12 10 16 0 -1 -3 -9 } [ copy-op < ] filter ;

: test-filter' ( -- x x ) 3 { -12 10 16 0 -1 -3 -9 } [ swap dup  rot < ] filter ;

: quicksort ( x -- x )
    [ { } ]
    [ dup dup dup 0 swap nth swap
      [ copy-op > ] filter quicksort
      swap rot [ copy-op = ] filter
      rot swap append
      swap rot [ copy-op < ] filter quicksort
      rot swap append
      swap drop
    ]
    if-empty ;


<PRIVATE
! Helpers for quicksort

! operation
: sfilter ( number list operation -- filtered number )
    ! for some reason compiled call's have to do this
    swap [ [ 2dup ] dip swap call( x x -- x ) ] filter swap drop swap ;

: on-car ( x quote  -- ? )
    [ car ] dip  call( x --  ? ) ;

PRIVATE>

: quicksort' ( xs -- xs )
    [ { } ]
    [ dup first swap
      [ [ > ] sfilter [ quicksort' ] dip ]
      [ [ = ] sfilter ]
      [ [ < ] sfilter [ quicksort' ] dip ] tri
      drop append append ]
    if-empty ;

: list-filter ( ... list quot: ( ... elt -- ... ? ) -- ... sub-list )
    over nil?
    [ drop ]
    [ 2dup
      on-car
      [ [ cdr ] dip list-filter ]
      [ over car rot cdr rot list-filter cons ]
      if ]
    if ;

