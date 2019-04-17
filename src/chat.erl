-module(chat).
-copyright('2014—2019 (c) Synrc Research Center').
-behaviour(application).
-behaviour(supervisor).
-include("message.hrl").
-include_lib("n2o/include/n2o.hrl").
-include_lib("kvx/include/metainfo.hrl").
-compile(export_all).

init(Req, Opts) -> {ok, Req, Opts}.

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
