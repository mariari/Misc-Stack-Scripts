! Copyright (C) 2023 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences typed accessors
syntax classes.tuple.parser arrays prettyprint
parser grouping hashtables assocs vectors words strings classes lexer
make quotations combinators math words.symbol namespaces ;
IN: extension.mop

<<

! ------------------------------------------------------------------
! errors
! ------------------------------------------------------------------

ERROR: invalid-syntax word ;

ERROR: redefinition word ;

! ------------------------------------------------------------------
! Standard class
! ------------------------------------------------------------------

TUPLE: standard-class
    { name }
    { direct-superclasses   sequence }
    { direct-slots          sequence }
    { class-precedence-list sequence }
    { effective-slots       sequence }
    { direct-subclasses     sequence initial: { } }
    { direct-methods        sequence initial: { } } ;


TYPED: class-direct-superclasses ( s: standard-class -- s: sequence )
    direct-subclasses>> ;

! ------------------------------------------------------------------
! SYMBOL declarations
! ------------------------------------------------------------------

SYMBOL: initarg: inline

SYMBOL: initform: inline

SYMBOL: initfunction: inline

SYMBOL: reader: inline

SYMBOL: writer: inline

SYMBOL: accessor: inline

SYMBOL: type: inline

SYMBOL: name: inline

SYMBOL: metaclass: inline

SYMBOL: default-initargs: inline

SYMBOL: table

table [ H{ } ] initialize

! ------------------------------------------------------------------
! Top level hash table declaration
! ------------------------------------------------------------------

: find-class ( name -- class )
    table get at ;

: set-class ( class name -- )
    table get set-at ;

! ------------------------------------------------------------------
! Helpers for Canonicalize
! ------------------------------------------------------------------

TYPED: inline-names ( a: array -- seq ) [ rest ] [ first create-word-in ] bi prefix ;

TYPED: setup-direct-slot ( spec: union{ array string } -- spec: union{ array word } )
    dup class-of string = [ create-word-in ] [ inline-names ] if ;

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

! ------------------------------------------------------------------
! Parser words for DEFCLASS:
! ------------------------------------------------------------------

: canonicalize-direct-slots ( spec -- slots-spec )
    [ setup-direct-slot canonicalize-direct-slot ] map ;

: scan-slots ( -- slots )
    scan-token dup "{" = [ drop ] [ invalid-syntax ] if
    [ "}" parse-tuple-slots-delim ] { } make ;

: scan-options ( -- options )
    [ parse-tuple-slots ] { } make ;

: (parse-class) ( -- name inheritance-list slots options )
    scan-new-word
    scan-object  canonicalize-direct-superclass
    scan-slots   canonicalize-direct-slots
    scan-options [ setup-direct-slot ] map ;

! ------------------------------------------------------------------
! central class definition
! ------------------------------------------------------------------

:: ensure-class ( name is slots options -- )
    ! define-symbol
    name dup find-class
    [ drop ]
    [ define-symbol
      ! we ignore the options for now
      name is slots { } { } { } { } standard-class boa name set-class
    ]
    if  ;

SYNTAX: DEFCLASS:
    (parse-class) ensure-class ;

>>

DEFCLASS: test { } { } ;

DEFCLASS: standard { test }
   { name
     { direct-superclasses   type: sequence }
     { direct-slots          type: sequence }
     { class-precedence-list type: sequence }
     { effective-slots       type: sequence }
     { direct-subclasses     initarg: { } }
     { direct-methods        type: sequence initarg: { } initform: [ 2 3 + ] } }
    { :metaclass standard-class } ;
