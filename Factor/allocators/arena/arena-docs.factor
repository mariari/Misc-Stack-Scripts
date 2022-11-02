USING: assocs help.markup help.syntax kernel math
       quotations words words.symbol alien
       allocators.arena.private ;
QUALIFIED-WITH: alien.c-types c
IN: allocators.arena

HELP: <arena>
{ $description
  "initalize the arena with a pre-allocated memory buffer" } ;

HELP: nearest-align
{ $description
  "Grabs the nearest "
  { $link alien }
  " address at a specific alignment offset" } ;

HELP: align-forward
{ $description
  "Aligns the given "
  { $link alien }
  " address forward to the next aligned address " } ;
