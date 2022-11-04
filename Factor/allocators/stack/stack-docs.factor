! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel alien allocators.stack.private ;
IN: allocators.stack

HELP: <header>
{ $values
    { "padding" object }
    { "header" object }
}
{ $description "" } ;

HELP: <stack>
{ $values
    { "buffer" object } { "length" object }
    { "s" object }
}
{ $description "" } ;

HELP: address-before-allocation
{ $values
    { "x" alien }
}
{ $description "address before the given allocation" } ;

HELP: alloc
{ $values
    { "s" object } { "size" object }
    { "a" object }
}
{ $description "" } ;

HELP: alloc-align
{ $values
    { "s" object } { "size" object } { "align" object }
    { "a" object }
}
{ $description "" } ;

HELP: calc-padding-with-header
{ $values
    { "ptr" object } { "align" object } { "header-size" object }
    { "padding" object }
}
{ $description "" } ;

HELP: current-address
{ $values
    { "s" object }
    { "c" object }
}
{ $description "" } ;

HELP: foo
{ $description "" } ;

HELP: free
{ $values
    { "s" object } { "ptr" object }
}
{ $description "" } ;

HELP: header
{ $class-description "" } ;

HELP: header-offset
{ $values
    { "-header-size" object }
}
{ $description "" } ;

HELP: header-size
{ $values
    { "fixnum" object }
}
{ $description "" } ;

HELP: read-header
{ $values
    { "address" object }
    { "h" object }
}
{ $description "" } ;

HELP: read-header-directly
{ $values
    { "address" object }
    { "h" object }
}
{ $description "" } ;

HELP: resize
{ $values
    { "a" object } { "ptr" object } { "old-size" object } { "new-size" object }
    { "stack" object }
}
{ $description "" } ;

HELP: resize-align
{ $values
    { "s" object } { "ptr" object } { "old-size" object } { "new-size" object } { "align" object }
    { "s" object }
}
{ $description "" } ;

HELP: stack
{ $class-description "" } ;

HELP: stack-free-malloc
{ $values
    { "arena" object }
}
{ $description "" } ;

HELP: stack-malloc
{ $values
    { "size" object }
    { "stack" object }
}
{ $description "" } ;

HELP: unsafe-free
{ $values
    { "s" object } { "ptr" object }
}
{ $description "" } ;

ARTICLE: "allocators.stack" "allocators.stack"
{ $vocab-link "allocators.stack" }
;

ABOUT: "allocators.stack"
