! -*- Mode: FACTOR -*-
IN: scratchpad
USE: editors.emacs

USING: io io.servers io.sockets io.encodings.ascii kernel continuations math
       sequences destructors formatting tty-server
       fuel.remote ;

: ip4-current ( port -- inet4 )
    local-server resolve-host second ;

: open-port? ( inet -- ? )
    [ ascii <server> dispose t ] [ drop drop f ] recover ;

: find-free-port ( port -- fixnum )
    dup ip4-current open-port?
    [ 1 + find-free-port ] unless ;


9000 find-free-port
[ "server started at port %s" printf nl ] [ fuel-start-remote-listener ] bi

