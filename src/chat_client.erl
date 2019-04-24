-module(chat_client).
-copyright('2014-2019 (c) Synrc Research Center').
-include("message.hrl").
-include_lib("kvx/include/cursors.hrl").
-include_lib("n2o/include/n2o.hrl").
-compile(export_all).

info({text,<<"N2O",X/binary>>},R,S) -> % auth
   Str = string:trim(binary_to_list(X)),
   n2o:reg({client,Str}),
   A = list_to_binary(Str),
   case kvx:get(writer,A) of
        {error,_} -> kvx:save(kvx:writer(A));
        {ok,_} -> skip end,
   {reply,{text,<<"USER ",A/binary>>},R,S#cx{session = A}};

info({text,<<"SAY",X/binary>>},R,#cx{session = Sid}=S) -> % send message
   C  = string:trim(binary_to_list(X)),
   case string:tokens(C," ") of
        [From,To,Id|Rest] ->
           Key = case Id of "0" -> kvx:seq([],[]); I -> I end,
           Msg = #'Message'{id=Key,from=From,to=To,files=[#'File'{payload=string:join(Rest," ")}]},
           Res = case user(From) andalso user(To) of
                 false -> <<"ERR user doesn't exist.">>;
                 true  -> % here is feed consistency happens
                          {ring,N} = n2o_ring:lookup({p2p,From,To}),
                          n2o:send({server,N},{publish,self(),Sid,Msg}),
                          <<>> end,
            {reply, {text, Res},R,S};
       _ -> {reply, {text, <<"ERROR in request.">>},R,S} end;

info({text,<<"LOG",X/binary>>},R,S) -> % print the feed
   C  = string:trim(binary_to_list(X)),
   case string:tokens(C," ") of
        [From,To] -> % we could perform database retrivals directly in WebSocket channel
           Key = chat:key({p2p,From,To}),
           kvx:ensure(#writer{id=Key}),
           Fetch = (kvx:take((kvx:reader(Key))#reader{args=-1}))#reader.args,
           Res = string:join([ format_msg(M) || M <- Fetch ],"\n"),
           {reply,{text,<<(list_to_binary(format_chat(Key)))/binary,
                          (list_to_binary(Res))/binary>>},R,S};
      _ -> {reply,{text,<<"ERROR in request.">>},R,S} end;

info({text,<<"HLP">>},R,S) -> % erase the feed by SEEN command
   {reply, {text,<<"N2O <bin>\n| SAY <from> <to> <0|key> <msg>\n| LOG <from> <to>\n| CUT <id>.">>},R,S};

info({text,<<"CUT",X/binary>>},R,S) -> % erase the feed by SEEN command
   C  = string:trim(binary_to_list(X)),
   _R = case string:tokens(C," ") of
        [From,To,Id] -> case kvx:cut({p2p,From,To},Id) of
                             {ok,Count} -> {reply,{text,<<"ERASED ",(bin(Count))/binary>>},R,S};
                             {error,_} -> {reply,{text,<<"NOT FOUND ">>},R,S} end;
                   _ -> {reply,{text,<<"ERROR in request.">>},R,S} end;

info({flush,#'Message'{}=M},R,S)  -> {reply, {text,<<"NOTIFY ",(list_to_binary(format_msg(M)))/binary>>},R,S};
info(#'Ack'{id=Key}, R,S) -> {reply, {text,<<"ACK ",(bin(Key))/binary>>},R,S};
info({flush,Text},R,S)    -> {reply, {text,Text},R,S};
info({text,_}, R,S)       -> {reply, {text,<<"Try HLP">>},R,S};
info(Msg, R,S)            -> {unknown,Msg,R,S}.

bin(Key) -> list_to_binary(io_lib:format("~p",[Key])).
format_chat({p2p,From,To}) -> io_lib:format("CHAT ~s ~s~n",[From,To]).
user(Id) -> case kvx:get(writer,n2o:to_binary(Id)) of {ok,_} -> true; {error,_} -> false end.

format_msg(#'Message'{id=Id,from=From,to=To,files=Files}) ->
  P = case Files of [#'File'{payload=X}] -> X; _ -> [] end,
  io_lib:format("~s:~s:~s:~s",[From,To,Id,P]).

