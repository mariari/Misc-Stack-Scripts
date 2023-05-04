\ Our machine is very simple.
\ We define out our op-codes, these are our byte-code.

\ We are making a STACK based VM. Which has 2 stacks

\ We have a data stack, and a parameter stack.

\ The current location of execution in the data stack is determined by
\ OUR Instruction Pointer (IP)

\ | Stack     | Representation in Forth |
\ |-----------+-------------------------|
\ | Return    | stack% in RETURN        |
\ | parameter | stack% in PARAMETER     |


require ./mmap.fs

#0 Constant VM-LITERAL \ 1 byte | 1 Word
#1 Constant VM-CALL    \ 1 byte | 1 Word
#2 Constant VM-DIΕ     \ 1 byte
#3 Constant VM-RETURN  \ 1 byte
#4 Constant VM-BRANCH  \ 1 byte | 1 Word ... offset?

Variable IP

0 IP !

Variable RETURN
Variable PARAMETER


struct
  cell% field object-type \ this tag determines what kind of object it is
  cell% field object-data \ we can save the word as a single cell
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

: push! ( data stack -- )
  tuck stack-top @ ! dup stack-top @ cell+ swap ! ;

: pop! ( stack -- data )
  dup dup stack-top @ cell- swap ! stack-top @ @ ;

: stack-dump ( -- ) ;

\ Run the op codes, we only handle the ones we know about


\ given the IP, run the needed code and increment the IP
\ We've already checked the first byte is 0.
\ Now simply read the next word, and push it on the stack
: run-literal ( PARAMETER IP -- )
  1 over +! 1 cells swap +!@ @ swap push! ;

\ TODO should we pass in the Ideally we should pass these all in, in a
\ struct
\ this is the behavior of immediate mode
: run-machine ( -- ??? ) recursive
  PARAMETER @ IP dup @ C@
  case
    VM-LITERAL of run-literal true endof
    VM-DIΕ     of 2drop false endof
    2drop false \ get an unknown, just false
  endcase
  if run-machine then ;


\ if you want to have an interpreter in the vm, then you need enough
\ expression for calling, and branching....
\ the IP is always moving forward, thus we set it up such that

\ ret returns back. all functions ret, like in forth, except our repl,
\ which always loops

\ since we don't have that yet, we are just going to run our words on
\ a loaded file. However when we get more advanced, we'll start from
\ the interpreter word itself, and go from there.


CREATE EXAMPLE VM-LITERAL C, 255 ,
               VM-LITERAL C, 355 ,
               VM-DIΕ     C,

: fake-startup ( -- )
  1024 stack-new PARAMETER !
  EXAMPLE IP ! ;

\ turn this into a load file and interpreter later when we support more
: entry ( -- )
  fake-startup run-machine          \ run it!
  PARAMETER @ stack-array @ 32 dump \ we should have written the first 16
;
