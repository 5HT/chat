-ifndef(KVS_HRL).
-define(KVS_HRL, true).


-define(CONTAINER, id=[] :: [] | integer(),
                   top=[] :: [] | integer(),
                   rear=[] :: [] | integer(),
                   count=0 :: integer()).

-define(ITERATOR(Container), id=[] :: [] | integer(),
                             container=Container :: atom(),
                             feed_id=[] :: term(),
                             prev=[] :: [] | integer(),
                             next=[] :: [] | integer(),
                             feeds=[] :: list()).

-record(id_seq,    {thing, id}).
-record(container, {?CONTAINER}).
-record(iterator,  {?ITERATOR([])}).
-record(block,     {left,right,name,last}).
-record(log,       {?CONTAINER, name, acc}).
-record(operation, {?ITERATOR(log), body=[], name=[], status=[]}).
-record(kvs,       {mod,cx}).

-compile({no_auto_import,[put/2]}).

-endif.
