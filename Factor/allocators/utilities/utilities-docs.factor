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

HELP: +-address
{ $values
    { "a" object } { "f" object }
    { "a+f" object }
}
{ $description "" } ;

HELP: G
{ $values
    { "number" object }
    { "GBs" object }
}
{ $description "" } ;

HELP: K
{ $values
    { "number" object }
    { "KBs" object }
}
{ $description "" } ;

HELP: M
{ $values
    { "number" object }
    { "MBs" object }
}
{ $description "" } ;

HELP: align-to-nearest
{ $values
    { "v" object } { "b" object }
    { "n" "an " { $link integer } " multiple of v" }
}
{ $description "a generalization of " { $link align } } ;

HELP: below-bounds?
{ $values
    { "address" object } { "bounds" object }
    { "below?" object }
}
{ $description "" } ;

HELP: bounds
{ $class-description "" } ;

HELP: memmove
{ $values
    { "dst" object } { "src" object } { "size" object }
    { "void*" object }
}
{ $description "" } ;

HELP: offset-from-base
{ $values
    { "address" object } { "bounds" object }
    { "offset-from-base" object }
}
{ $description "" } ;

HELP: padding-needed
{ $values
    { "align" object } { "address" object }
    { "padding-needed" object }
}
{ $description "" } ;

HELP: padding-needed-2^
{ $values
    { "align-pow-2" object } { "address" object }
    { "padding-needed" object }
}
{ $description "" } ;

HELP: padding-needed-2^-checked
{ $values
    { "align-pow-2" object } { "address" object }
    { "padding-needed" object }
}
{ $description "" } ;

HELP: past-bounds?
{ $values
    { "address" object } { "bounds" object }
    { "past?" object }
}
{ $description "" } ;

HELP: within-bounds?
{ $values
    { "address" object } { "b" object }
    { "b" object }
}
{ $description "" } ;

ARTICLE: "allocators.utilities" "allocators.utilities"
{ $vocab-link "allocators.utilities" }
;

ABOUT: "allocators.utilities"
