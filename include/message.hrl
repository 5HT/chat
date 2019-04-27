-ifndef(MESSAGE_HRL).
-define(MESSAGE_HRL, true).

-record(muc,   { name      = [] :: [] | binary() }).
-record(p2p,   { from      = [] :: [] | binary(),
                 to        = [] :: [] | binary() }).

-record('Ack', { id        = [] :: [] | integer(),
                 table     = [] :: [] | atom() }).

-record('Bin', { id        = [] :: binary(),
                 mime      = <<"text">> :: binary(),
                 payload   = [] :: binary(),
                 parentid  = [] :: binary()}).

-record('Msg', { id        = [] :: [] | integer(),
                 client_id = [] :: [] | binary(),
                 from      = [] :: [] | binary(),
                 to        = [] :: [] | binary(),
                 files     = [] :: list(#'Bin'{}),
                 type      = [] :: [] | atom()}).

-record('Log', { feed      = [] :: [] | #p2p{} | #muc{},
                 id        = [] :: [] | integer(),
                 data      = [] :: list(#'Msg'{}),
                 length    = [] :: [] | integer()}).

-endif.
