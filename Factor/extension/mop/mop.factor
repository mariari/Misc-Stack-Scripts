! Copyright (C) 2023 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences typed accessors
       syntax classes.tuple.parser arrays prettyprint
       parser grouping hashtables assocs vectors words strings classes lexer
       make quotations combinators math words.symbol namespaces
       vocabs.parser lists continuations math.parser sets literals ;
IN: extension.mop

<<

! ------------------------------------------------------------------
! errors
! ------------------------------------------------------------------

ERROR: invalid-syntax word ;

ERROR: redefinition word ;

ERROR: improper-keyword-syntax word ;

ERROR: improper-word-creation word ;

ERROR: imporper-option-creation word ;

! ------------------------------------------------------------------
! Standard class
! ------------------------------------------------------------------

TUPLE: mop-standard-class
    { name }
    { direct-superclasses   sequence initial: { } }
    { direct-slots          sequence initial: { } }
    { class-precedence-list sequence initial: { } }
    { effective-slots       sequence initial: { } }
    { direct-subclasses     hashtable }
    { direct-methods        sequence initial: { } } ;

! make sure the values are unique
: new-mop-standard-class ( name -- mop )
    { } { } { } { } H{ } clone V{ } mop-standard-class boa ;

! ------------------------------------------------------------------
! SYMBOL declarations
! ------------------------------------------------------------------

SYMBOL: initarg: inline
SYMBOL: accessor: inline
SYMBOL: reader: inline
SYMBOL: writer: inline

SYMBOL: initform: inline
SYMBOL: initfunction: inline

SYMBOL: type: inline

SYMBOL: name: inline

SYMBOL: metaclass: inline

SYMBOL: default-initargs: inline
SYMBOL: default-initarg: inline

SYMBOL: table

SYMBOL: standard-object

<PRIVATE

: true-object-setup ( -- obj )
    t new-mop-standard-class ;

SYMBOL: true-object

true-object [ true-object-setup ] initialize

: standard-object-setup ( -- obj )
    standard-object new-mop-standard-class true-object get 1array >>direct-superclasses ;

SYMBOL: standard-object-object

standard-object-object [ standard-object-setup ] initialize

PRIVATE>

table
[ standard-object standard-object-object get 2array
  t               true-object            get 2array
  2array >hashtable ] initialize

! ------------------------------------------------------------------
! Top level hash table declaration
! ------------------------------------------------------------------

: find-class ( name -- class )
    table get at ;

: set-class ( class name -- )
    table get set-at ;

! ------------------------------------------------------------------
! Canonicalize definitions
! ------------------------------------------------------------------

TYPED: canonicalize-direct-superclass ( class-names: array -- array )
    [ find-class ] map ;

TYPED: canonicalize-direct-slot ( spec: union{ array word } -- s )
    dup word instance?
    [ name: associate >hashtable ]
    [ [ rest 2 group ] [ first name: associate ] bi
      >hashtable
      [ first2 swap
        { { initform: [ [ >quotation initfunction: rot set-at ]
                        [ initform: rot set-at ]
                        [ drop ]
                        2tri ] }
          [ pick push-at ]
        } case
      ] reduce ]
    if ;

: canonicalize-direct-slots ( spec -- slots-spec )
    [ canonicalize-direct-slot ] map ;

! ------------------------------------------------------------------
! Parser words for DEFCLASS:
! ------------------------------------------------------------------

: intern-word ( string -- word )
    dup search [ nip ] [ dup string>number [ drop ] [ create-word-in ] if* ] if* ;

: end-check ( str -- str )
    dup [ \ } "}" "{" "[" "]" "(" ")" ] member? [ improper-word-creation ] [ ] if ;

: scan-intern-word ( -- word )      scan-token end-check intern-word ;
: scan-slot-name   ( -- slot-name ) scan-intern-word ;
: scan-keyword     ( -- keyword )   scan-word ;

: new-definers-list ( -- definers )
    { initarg: reader: writer: accessor: metaclass: } ;

: parse-slot-options ( accumulator -- x )
    scan-token
    { { [ dup "}" = ] [ drop lreverse ] }
      { [ search dup new-definers-list member? ]
        [ swons scan-intern-word swons parse-slot-options ] }
      { [ dup ]
        [ swons scan-object swons parse-slot-options ] }
      [ <no-word-error> throw-restarts ]
    } cond ;

: parse-slot ( -- spec )
    [ scan-slot-name , nil parse-slot-options list>array % ] { } make ;

: parse-slots ( end-delim string/f -- ? )
    { { [ dup { ":" "(" "<" "\"" "!" } member? ]
        [ invalid-slot-name ] }
      { [ 2dup = ]
        [ drop f ] }
      [ dup "{" = [ drop parse-slot ] when , t ]
    } cond nip ;

: parse-slots-until ( end-delim -- )
    dup scan-token parse-slots [ parse-slots-until ] [ drop ] if ;

: parse-option  ( -- spec )
    [ nil parse-slot-options list>array % ] { } make ;

: parse-options ( end-delim string/f -- ? )
    { { [ 2dup = ]    [ drop f ] }
      { [ dup "{" = ] [ nip parse-option , t ]  }
      [ imporper-option-creation f ]
    } cond nip ;

! bad please refactor
: parse-options-until ( end-delim -- )
    dup scan-token parse-options [ parse-slots-until ] [ drop ] if ;

: scan-slots ( -- slots )
    scan-token dup "{" = [ drop ] [ invalid-syntax ] if
    [ "}" parse-slots-until ] { } make ;

: scan-options ( -- options )
    [ ";" parse-options-until ] { } make ;

: (parse-class) ( -- name inheritance-list slots options )
    scan-intern-word
    scan-object canonicalize-direct-superclass
    scan-slots  canonicalize-direct-slots
    scan-options ;

! ------------------------------------------------------------------
! Class final initalization
! ------------------------------------------------------------------

TYPED: default-superclasses ( -- a: array )
   standard-object find-class 1array ;

TYPED: make-direct-slot-definition ( h: hashtable -- h: hashtable ) ;

TYPED: initalize-writers ( c: mop-standard-class s: sequence -- )
    2drop ;

TYPED: initalize-readers ( c: mop-standard-class s: sequence -- )
    2drop ;

TYPED: finalize-inheritance ( c: mop-standard-class -- )
    drop ;

: add-to-subclass ( class to-add -- )
    dup name>> rot direct-subclasses>> set-at ;

TYPED: initalize-superclasses ( c: mop-standard-class -- )
    [ [ default-superclasses ] when-empty ] change-direct-superclasses drop ;

TYPED:: initialize-superclasses-to-have-subclass ( c: mop-standard-class -- )
    c direct-superclasses>> [ c add-to-subclass ] each ;

TYPED: initialize-direct-slots ( c: mop-standard-class -- )
    [ [ make-direct-slot-definition ] map ] change-direct-slots drop ;

TYPED: initalize-slot-mehthods ( c: mop-standard-class -- )
    dup direct-slots>> [ initalize-writers ] [ initalize-readers ] 2bi ;

TYPED: initialize-standard-class ( c: mop-standard-class -- c: mop-standard-class )
    dup
    { [ initalize-superclasses ]
      [ initialize-superclasses-to-have-subclass ]
      [ initialize-direct-slots ]
      [ initalize-slot-mehthods ]
      [ finalize-inheritance ]
    } cleave ;

! ------------------------------------------------------------------
! central class definition
! ------------------------------------------------------------------

:: define-class ( name is slots -- )
    name is slots { } { } H{ } clone V{ } mop-standard-class boa initialize-standard-class
    name set-class ;

:: ensure-class ( name is slots options -- )
    name dup find-class
    ! we ignore the options for now, and let redefines happen
    [ define-symbol name is slots define-class ] dup if ;

SYNTAX: DEFCLASS:
    (parse-class) ensure-class ;

>>

standard-object-object get initialize-standard-class drop

DEFCLASS: test-class { standard-object } { } ;

DEFCLASS: standard-test { test-class }
   { { name }
     { direct-superclasses   type: sequence }
     { direct-slots          type: sequence }
     { class-precedence-list type: sequence }
     { effective-slots       type: sequence }
     { direct-methods        type: sequence initform: [ 2 3 + ] }
     { direct-subclasses     initarg: initform: { } accessor: class-direct-subclasses } }
   { default-initarg: [ ] } ;

DEFCLASS: standard-class { }
   { { name initarg:  name:
            accessor: class-name }
     { direct-superclasses initarg: direct-superclasses:
                           accessor: class-direct-superclasses }
     { direct-slots type: sequence
                    accessor: class-slots }
     { class-precedence-list type: sequence
                             accessor: class-precedence-list }
     { effective-slots type: sequence
                       accessor: class-slots }
     { direct-subclasses initarg: initform: { }
                         accessor: class-direct-subclasses }
     { direct-methods initarg: initform: { }
                      accessor: class-direct-methods } }
   { metaclass: standard-class }
   { default-initarg: [ ] } ;
