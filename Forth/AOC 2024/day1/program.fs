( Day 1 AOC 2024 )
marker day1

include ../common.fs
include input depth 2/ dup
constant input-length

cells dup
create list1 allot
create list2 allot

: load-list
  cells 0 ?do
    list1 i + ! list2 i + ! cell
  +LOOP ;

: list-count ( u arr n - u )
  0 -rot cell array>mem mem-do
    over i @ = if 1+ then
  LOOP nip ;

: part1 ( -- u )
  0 input-length cells 0 ?do
    list1 i + @ list2 i + @ - abs + cell
  +LOOP ;

: part2 ( -- u )
  0 list1 input-length cells bounds ?do
    i @ dup list2 input-length list-count * + cell
  +LOOP ;

input-length load-list
list1 input-length sort
list2 input-length sort

cr ." part1: " part1 .
cr ." part1: " part2 .
