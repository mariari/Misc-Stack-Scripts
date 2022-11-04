! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math ;
IN: allocators.utilities

HELP: default-alignment
{ $values
    { "aliignment" fixnum }
}
{ $description "the default alignment on the system" } ;

HELP: assert-2^
{ $values
    { "address" object }
}
{ $description "" } ;

HELP: mod-2^
{ $values
    { "value" object } { "power" object }
    { "modded-value" object }
}
{ $description
  "Mods the given value by a power of two. This method is faster than "
  { $link mod }
  " given powers of two" } ;

HELP: 2^?
{ $values
    { "address" number }
    { "aligned?" boolean }
}
{ $description "" } ;

ARTICLE: "allocators.utilities" "allocators.utilities"
{ $vocab-link "allocators.utilities" } ;

ABOUT: "allocators.utilities"
