-module(chat_server).
-copyright('2014—2019 (c) Synrc Research Center').
-include("message.hrl").
-include_lib("kvx/include/cursors.hrl").
-include_lib("n2o/include/n2o.hrl").
-compile(export_all).

info(#'Message'{from=From,to=To,id=Id}=M, R, S) ->
   kvx:append(M,chat:key({p2p,From,To})),
   n2o:send({client,To},{flush,M}),
   {reply,{binary, #'Ack'{id=Id}},R,S};

info(Msg, R,S) ->
   {unknown,Msg,R,S}.

