USING: assocs help.markup help.syntax kernel math
namespaces.private quotations words words.symbol alien ;
QUALIFIED-WITH: alien.c-types c
IN: allocators.arena-global

HELP: index-address
{ $description
  "gives back a new "
  { $link alien }
  " address that is offset from the original address"
  " by n bytes, where n is the index times the size of the "
  { $link c:c-type } "." } ;
