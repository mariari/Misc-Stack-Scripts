! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math kernel sequences graphviz.render
       compiler.cfg.debugger compiler.cfg compiler.cfg.graphviz compiler.codegen tools.disassembler
       prettyprint ;
IN: misc.compiler


: dump-code ( sequence -- )
    test-regs first dup cfg set [ cfgviz preview ] [ generate . ] [ generate 4 swap nth disassemble ] tri ;


: dump-basic-if ( -- ) [ get [ t ] [ 3 4 + ] if ] dump-code ;
