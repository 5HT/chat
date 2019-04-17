-module(chat).
-copyright('2014—2019 (c) Synrc Research Center').
-behaviour(application).
-behaviour(supervisor).
-include("message.hrl").
-include_lib("n2o/include/n2o.hrl").
-include_lib("kvx/include/metainfo.hrl").
-compile(export_all).

malformed_request(R,S)      -> cowboy_static:malformed_request(R,S).
forbidden(R,S)              -> cowboy_static:forbidden(R,S).
content_types_provided(R,S) -> cowboy_static:content_types_provided(R,S).
ranges_provided(R,S)        -> cowboy_static:ranges_provided(R,S).
resource_exists(R,S)        -> cowboy_static:resource_exists(R,S).
last_modified(R,S)          -> cowboy_static:last_modified(R,S).
generate_etag(R,S)          -> cowboy_static:generate_etag(R,S).
get_file(R,S)               -> cowboy_static:get_file(R,S).
websocket_init(S)           -> n2o_cowboy2:websocket_init(S).
websocket_handle(D,S)       -> n2o_cowboy2:websocket_handle(D,S).
websocket_info(D,S)         -> n2o_cowboy2:websocket_info(D,S).

index() -> [n2o_cowboy:fix1(code:priv_dir(?MODULE)), "/static/index.html"].

init(#{headers := #{<<"upgrade">> := <<"websocket">>}} = Req, _) -> {cowboy_websocket, Req, Req};
init(Req, _) ->
    Index = filename:absname(iolist_to_binary(index())),
    {ok, Info} = file:read_file_info(Index, [{time, universal}]),
    {cowboy_rest, Req, {Index, {direct, Info}, []}}.

endpoints() ->
    S = {dir, n2o_cowboy:fix1(code:priv_dir(?MODULE))++"/static", []},
    cowboy_router:compile([{'_', [{"/", ?MODULE, []},
        {"/app/[...]", cowboy_static, S},
        {"/[...]", cowboy_static, S}]}]).

stop(_)    -> ok.
start()    -> start(normal,[]).
start(_,_) -> X = supervisor:start_link({local,?MODULE},?MODULE,[]),
              syn:init(),
              kvx:join(),
              cowboy:start_tls(http,n2o_cowboy:env(?MODULE),#{env=>#{dispatch=>endpoints()}}),
              [ n2o_pi:start(#pi{module=n2o_wsnode,table=ring,
                                 sup=?MODULE,state=[],name={server,Pos}})
                || {{_,_},Pos} <- lists:zip(n2o:ring(),lists:seq(1,length(n2o:ring()))) ],
              X.
port()     -> application:get_env(n2o,port,8042).
init([])   -> {ok, {{one_for_one, 5, 10}, [ ] }}.
metainfo() -> #schema { name=roster, tables=[
              #table { name = 'Message', fields = record_info(fields,'Message')}
              ]}.
