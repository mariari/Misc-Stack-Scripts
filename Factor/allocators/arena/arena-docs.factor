! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel allocators.arena.private alien libc math ;
IN: allocators.arena

HELP: <save-point>
{ $values
    { "a" object }
    { "s" object }
}
{ $description "A save point for resetting to a previous allocation point" } ;

HELP: alloc
{ $values
    { "a" object } { "size" object }
    { "a" object }
}
{ $description "" } ;

HELP: alloc-align
{ $values
    { "arena" object } { "size" object } { "align" object }
    { "alien" object }
}
{ $description "" } ;

HELP: arena
{ $class-description "" } ;

HELP: <arena>
{ $values
    { "data" alien } { "length" fixnum } { "arena" arena } }
{ $description
  "initalize the arena with a pre-allocated memory buffer" } ;

HELP: nearest-align
{ $description
  "Grabs the nearest "
  { $link alien }
  " address at a specific alignment offset" } ;

HELP: current-address
{ $values
    { "arena" object }
    { "current" object }
}
{ $description "" } ;

HELP: memmove
{ $values
    { "dst" object } { "src" object } { "size" object }
    { "void*" object }
}
{ $description "" } ;

HELP: resize
{ $values
    { "a" object } { "old-memory" object } { "old-size" object } { "new-size" object }
    { "alien" object }
}
{ $description "" } ;

HELP: resize-align
{ $values
    { "a" object } { "old-memory" object } { "old-size" object } { "new-size" object } { "align" object }
    { "a" object }
}
{ $description "" } ;

HELP: restore
{ $values
    { "s" object }
}
{ $description "" } ;

HELP: snapshot
{ $values
    { "a" object }
    { "s" object }
}
{ $description "" } ;

HELP: align-forward
{ $description
  "Aligns the given "
  { $link alien }
  " address forward to the next aligned address " } ;

HELP: free
{ $description
  "Frees the given " { $link alien } " pointer from the " { $link arena }
  " For the arena allocator this does nothing" } ;

HELP: free-all
{ $description
  "Frees all memory in the " { $link arena } } ;

HELP: arena-malloc
{ $description
  "Backs an arena with " { $link malloc } } ;

HELP: arena-free-malloc
{ $description
  "Frees a " { $link malloc } " based " { $link arena } } ;

ARTICLE: "allocators.arena" "allocators.arena"
{ $vocab-link "allocators.arena" }
;

ABOUT: "allocators.arena"
