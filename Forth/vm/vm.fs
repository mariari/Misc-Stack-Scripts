\ Our machine is very simple.
\ We define out our op-codes, these are our byte-code.

\ We are making a STACK based VM. Which has 2 stacks

\ We have a data stack, and a parameter stack.

\ The current location of execution in the data stack is determined by
\ OUR Instruction Pointer (IP)

\ | Stack     | Representation in Forth |
\ |-----------+-------------------------|
\ | Return    | stack% in RETURN        |
\ | Parameter | stack% in PARAMETER     |
\ | Vector    | stack% in VECTOR        |

require ./mmap.fs

#0 Constant VM-LITERAL \ 1 byte | 1 Word
#1 Constant VM-CALL    \ 1 byte | 1 Word
#2 Constant VM-DIE     \ 1 byte
#3 Constant VM-RETURN  \ 1 byte
#4 Constant VM-BRANCH  \ 1 byte | 1 Word ... offset?
#5 Constant VM-EMIT    \ 1 byte

Variable IP

0 IP !

Variable RETURN
Variable PARAMETER
Variable VECTOR

\ Data Layout
\ We shall represent nodes like this

\ Object Node On the stack (size 1 cell)
\ --------------------------------------
\
\ ------------
\ | b₁...b₆₄ |
\ ------------
\ Where b₆₄ represents if it's a tag or not.
\ b₆₄ = 1 ↦ the node is a pointer
\ b₆₄ = 0 ↦ the node is a fixnum

\ Object nodes live on the stack just natively, however if the node is
\ a pointer it has the following layout

\ Vector Object (size variable)
\ -----------------------------
\
\ -------------------------------
\ | b₁…b₈ | b₉…b₇₂ | b₇₃………|
\ |  Type  |  size   | data     |
\ -------------------------------

\ Tagged types

#0 Constant VM-Integer \ non fixnum integer
#1 Constant VM-String  \ We should really encode chars efficiently
#2 Constant VM-Array

struct
  char% field object-type \ this tag determines what kind of object it is
  cell% field object-size \ this tag determines the size the object is
  cell% field object-data \ The size of this does not matter, the
                          \ offset from this struct is what we want
end-struct object%

struct
  cell% field stack-top   \ top address
  cell% field stack-size  \ size of the array
  cell% field stack-array \ we are going to allocate the array elsewhere
end-struct stack%

\ create object-stack object% %allot

\ ------------------------
\    Some Helper words
\ ------------------------

: arr ( size -- addr ) here swap cells allot ;

\ took code from u.d, idk what #0 is
: u.l #0 ( u n -- ) swap >r <<# #s #> r> over - -rot type spaces #>> ;


\ increment the data inside by amnt
: incf ( a-addr n -- ) swap +! ;

: 1+! ( addr -- ) 1 incf ;
: -1+! ( addr -- ) -1 incf ;
: cell+! ( addr -- ) cell incf ;
: cell-! ( addr -- ) -1 cells incf ;

\ ------------------------
\   Stack Data Structure
\ ------------------------

\ we stack allocate this, we'll need a new version that can be mmaped
: stack-new ( n -- stack-addr )
  stack% %allot
  2dup stack-size !
  swap arr swap
  2dup stack-array !
  2dup stack-top !
  nip ;

: show-stack ( stack -- )
  dup dup CR decimal
  ." size" 12 spaces ." address" 8 spaces ." top" CR
  ." -------------------------------------------" CR
  stack-size  @ 16 u.l
  stack-array @ 15 hex u.l decimal
  stack-top   @ 15 hex u.l decimal ;

\ reserves u space in the stack, returning the original address
: stack-reserve { u stack -- u2 }
  stack stack-top @ { old-top }
  u old-top + aligned stack stack-top !
  old-top ;

\ I'm a helper for push! to add the data
: push-data! ( data stack -- stack ) tuck @ ! ;

: push!  ( data stack -- ) stack-top push-data! cell+! ;
: cpush! ( data stack -- ) stack-top push-data! 1+! ;

: pop!  ( stack -- data ) stack-top dup cell-! @ @ ;
: cpop! ( stack -- data ) stack-top dup -1+! @ @ ;


: stack-dump ( -- ) ;

\ ------------------------
\  Object Data Structure
\ ------------------------

\ We know that a value is a pointer, if it's a pointer with the LSB being 1
: top-pointer ( stack -- displaced-address )
  stack-top @ 1 lshift 1 or ;

: fixnum ( number -- tagged-number ) 1 lshift ;

: copy-char ( addr-from addr-to -- )
  swap c@ swap c! ;

: copy-string ( addr-from size addr-to -- )
  swap 0 ?DO
    over i + over i + copy-char
  LOOP 2drop ;

\ places a string header at the top of the stack
: place-string-header { length stack -- }
  stack stack-top @ { top }
  top object-data stack stack-top !
  VM-String top object-type !
  length    top object-size ! ;

\ Places a string at the top of the stack
: place-string ( string-addr length VECTOR -- )
  over swap stack-reserve copy-string ;

\ we just take a forth string and put it into our model
: string ( string-addr length vec -- loc )
  dup top-pointer >r
  2dup place-string-header place-string
  r> ;

\ Run the op codes, we only handle the ones we know about


\ given the IP, run the needed code and increment the IP
\ We've already checked the first byte is 0.
\ Now simply read the next word, and push it on the stack
: run-literal ( PARAMETER IP -- )
  1 over +! 1 cells swap +!@ @ swap push! ;

\ dumps the given literal to stdout
: emit-literal ( PARAMETER IP -- )
  1+! pop!
  dup 1 and 0= if
    1 rshift .
  else
    1 rshift dup object-type c@
    case
      VM-String of dup object-data swap object-size @ type endof
      drop
    endcase
  then ;

\ TODO should we pass in the Ideally we should pass these all in, in a
\ struct
\ this is the behavior of immediate mode
: run-machine ( -- ??? ) recursive
  PARAMETER @ IP dup @ C@
  case
    VM-LITERAL of run-literal  true  endof
    VM-DIE     of 2drop        false endof
    VM-EMIT    of emit-literal true  endof
    2drop false \ get an unknown, just false
  endcase
  if run-machine then ;


\ if you want to have an interpreter in the vm, then you need enough
\ expression for calling, and branching....
\ the IP is always moving forward, thus we set it up such that

\ If you want to have a leaner loader that just does the op-codes
\ I.E. run-machine, then you need to have definition creation in the
\ bytecode. However if you don't then you'll need to run "foreign"
\ code that manipulates the memory image and presents it back as a
\ user program

\ ret returns back. all functions ret, like in forth, except our repl,
\ which always loops

\ since we don't have that yet, we are just going to run our words on
\ a loaded file. However when we get more advanced, we'll start from
\ the interpreter word itself, and go from there.


\ fake example

CREATE EXAMPLE VM-LITERAL C, 255 , VM-LITERAL C, 355 , VM-DIE C,

: example-with-stirng { vec -- address }
  Here VM-LITERAL C, 255                  fixnum ,
       VM-LITERAL C, newline vec          string ,
       VM-LITERAL C, s" Hello, World" vec string ,
       VM-EMIT    C,
       VM-EMIT    C,
       VM-EMIT    C,
       VM-DIE     C, ;

: fake-startup ( -- )
  1024       stack-new PARAMETER !
  1024 cells stack-new VECTOR !
  VECTOR @ example-with-stirng IP ! ; \ setup the fake example program

\ turn this into a load file and interpreter later when we support more
: entry ( -- )
  cr
  fake-startup run-machine          \ run it!
  ." Vector Stack" cr
  ." ------------" cr
  vector @ stack-array @ 32 dump
  ." Parameter" cr
  ." ------------" cr
  vector @ stack-array @ 32 dump ;
