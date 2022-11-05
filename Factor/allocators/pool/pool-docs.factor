! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math ;
IN: allocators.pool

HELP: <pool>
{ $values
    { "buffer" object } { "length" object } { "chunk-size" object }
    { "pool" object }
}
{ $description "" } ;

HELP: <pool>-align
{ $values
    { "buffer" object } { "length" object } { "chunk-size" object } { "alignment" object }
    { "pool" object }
}
{ $description "" } ;

HELP: alloc
{ $values
    { "p" object }
    { "a" object }
}
{ $description "" } ;

HELP: buffer-displacement
{ $values
    { "x" object }
}
{ $description "" } ;

HELP: chunk-count
{ $values
    { "pool" object }
    { "count" object }
}
{ $description "" } ;

HELP: free
{ $values
    { "p" object } { "ptr" object }
}
{ $description "" } ;

HELP: free-all
{ $values
    { "p" object }
}
{ $description "" } ;

HELP: head-read
{ $values
    { "p" object }
    { "n" integer }
}
{ $description "" } ;

HELP: node
{ $class-description "" } ;

HELP: pool
{ $class-description "" } ;

HELP: pool-free-malloc
{ $values
    { "pool" object }
}
{ $description "" } ;

HELP: pool-init
{ $values
    { "pool" object } { "alignment" object }
}
{ $description "" } ;

HELP: pool-malloc
{ $values
    { "size" object } { "chunk-size" object }
    { "pool" object }
}
{ $description "" } ;

HELP: push-free-node
{ $values
    { "pool" object } { "node*" object }
}
{ $description "" } ;

ARTICLE: "allocators.pool" "allocators.pool"
{ $vocab-link "allocators.pool" }
;

ABOUT: "allocators.pool"
