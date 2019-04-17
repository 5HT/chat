-module(chat).
-copyright('2014—2019 (c) Synrc Research Center').
-behaviour(application).
-behaviour(supervisor).
-include("message.hrl").
-include_lib("n2o/include/n2o.hrl").
-include_lib("kvx/include/metainfo.hrl").
-compile(export_all).

init(Req, Opts) ->
    Body = <<"<script>window.location = 'https://chat.n2o.space';</script> Reticulating splines...">>,
    {ok, cowboy_req:reply(200, #{}, [Body, "\n"], Req), Opts}.

endpoints() ->
    Static = {dir, n2o_cowboy:fix1(code:priv_dir(application:get_env(n2o,app,chat)))++"/static", []},
    cowboy_router:compile([{'_', [
        {"/", ?MODULE, []},
        {"/ws/[...]", n2o_cowboy2, []},
        {"/n2o/[...]", cowboy_static, {dir, n2o_cowboy:fix2(code:priv_dir(n2o)), []}},
        {"/app/[...]", cowboy_static, Static},
        {"/[...]", cowboy_static, Static}]}]).

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
