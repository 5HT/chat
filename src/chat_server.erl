-module(chat_server).
-include("message.hrl").
-compile(export_all).

info(#'Message'{to=To,id=Id}=Msg, R, S) ->
   kvx:append(Msg,To),
   n2o:send({client,To},{flush,Msg}),
   {reply,{binary, #'Ack'{id=Id}},R,S};

info(Msg, R,S) ->
   {unknown,Msg,R,S}.
