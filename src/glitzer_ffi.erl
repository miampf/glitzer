-module(glitzer_ffi).

% Public API
-export([sleep/1]).

sleep(Int) ->
  timer:sleep(Int).
