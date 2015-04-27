-module(roster_group).
-author('Maxim Sokhatsky').
-include("SMP.hrl").
-include_lib("kvs/include/group.hrl").
-behaviour(gen_server).
-export(?GEN_SERVER).
-compile(export_all).

start_link(Parameters) -> gen_server:start_link(?MODULE, Parameters, []).

handle_call({get},_,Proc)              -> { reply,Proc,Proc };
handle_call(Command,_,Proc)            -> { reply,{unknown,Command},Proc }.

init(Group) ->
    wf:info(?MODULE,"Group ~p spawned ~p",[Group#group.id,self()]),
    G = case kvs:get(group,Group#group.id) of
         {ok,Exists} -> Exists;
           {error,_} -> Group end,
    wf:cache({group,G#group.id},self()),
    {ok, G#group{}}.

handle_cast(Msg, State) ->
    wf:info(?MODULE,"Unknown API async: ~p", [Msg]),
    {stop, {error, {unknown_cast, Msg}}, State}.

handle_info({'DOWN', _MonitorRef, _Type, _Object, _Info} = Msg, State = #group{id=Id}) ->
    wf:info(?MODULE, "connection closed, shutting down session:~p", [Msg]),
    wf:cache({group,Id},undefined),
    {stop, normal, State};

handle_info(Info, State=#group{}) ->
    wf:info(?MODULE,"Unrecognized info: ~p", [Info]),
    {noreply, State}.

terminate(_Reason, #group{id=Id}) ->
    wf:info(?MODULE,"Terminating session Id cache: ~p", [Id]),
    wf:cache({group,Id},undefined),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

