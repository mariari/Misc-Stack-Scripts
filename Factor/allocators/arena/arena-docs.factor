USING: assocs help.markup help.syntax kernel math
       quotations words words.symbol alien
       allocators.arena.private libc ;
QUALIFIED-WITH: alien.c-types c
IN: allocators.arena

HELP: save-point
{ $description
  "A save point for resetting to a previous allocation point" } ;

HELP: <arena>
{ $description
  "initalize the arena with a pre-allocated memory buffer" } ;

HELP: nearest-align
{ $description
  "Grabs the nearest "
  { $link alien }
  " address at a specific alignment offset" } ;

HELP: power-of-two?
{ $description
  "Mods the given value by a power of two. This method is faster than "
  { $link mod }
  " given powers of two" } ;

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
