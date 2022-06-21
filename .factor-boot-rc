! -*- Mode: FACTOR -*-
IN: scratchpad
USING: io io.servers io.sockets io.encodings.ascii kernel continuations math
       sequences destructors formatting tty-server tools.scaffold
       fuel.remote namespaces
       editors.emacs ;

"mariari" developer-name set-global

: ip4-current ( port -- inet4 )
    local-server resolve-host second ;

: open-port? ( inet -- ? )
    [ ascii <server> dispose t ] [ drop drop f ] recover ;

: find-free-port ( port -- fixnum )
    dup ip4-current open-port?
    [ 1 + find-free-port ] unless ;

: remote-start ( -- )
    9000 find-free-port
    [ "server started at port %s" printf nl ] [ fuel-start-remote-listener ] bi ;

