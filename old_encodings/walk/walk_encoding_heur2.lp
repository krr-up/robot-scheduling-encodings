% ------------------------------------------------------------------------------
% Domain heuristics for the walk encoding.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% If we have precomputed shortest path information (in the form of the
% shortest_path/4 predicate) then we can track the minimum path for each
% task-path object.
%
% on_minpath(P,Src,Via) - for the robot executing the path P, if it is currently
% at Src then Via is on the minimum path to the destination for P.
% ------------------------------------------------------------------------------

% Uses domain predicates as much as possible. Only path_sequence/2 involves
% choices.

on_path(R,0,V)    :- start(R,V), assignment(R,_).
on_path(R,S,V)    :- assignment(R,T), proj(T,S), task(T,V).

on_path(T,S+1,V')  :- walk(R,S,V), shortest_path(V,Dst,_,V'),
                      task(T,Dst), assignment(R,T), proj(T,S''), S < S'',
                      #false : assignment(R,T'), proj(T',S'), S < S', S' <  S''.

%on_minpath(T,S+1,V)    :- walk(R,S,V), task(T,Dst), shortest_path(V,Dst,_,V').

#heuristic walk(R,S,V) : on_path(R,S,V).   [1,true]



%%on_path(R,0,V)    :- start(R,V), assignment(R,T), not task_sequence(_,T).
%%on_path(T',S,Src) :- task_sequence(T,T'), proj(T,S), task(T,Src).

%%on_minpath(T,S+1,V)    :- on_minpath(T,S,Src), task(T,Dst), shortest_path(Src,Dst,_,V).

%%on_minpath(T,S+1,V)    :- walk(R,S,V), task(T,Dst), shortest_path(V,Dst,_,V').

%%#heuristic walk(R,S,V) : on_minpath(T,S,V), assignment(R,T).   [1,true]

%on_minpath(R,Src,V)     :- start(R,Src), not task_sequence(,), task(R,Dest),
%                           shortest_path(Src,Dest,_,V).
%on_minpath(P',Src,V)    :- path_sequence(P,P'), path(P,Src), path(P',Dest),
%                           shortest_path(Src,Dest,_,V).
%on_minpath(P,Src,V)     :- on_minpath(P,_,Src), path(P,Dest),
%                           shortest_path(Src,Dest,_,V).

% ------------------------------------------------------------------------------
% Domain heuristic for moves based on being on the shortest path
% ------------------------------------------------------------------------------

%#heuristic move(P,V,V')      : on_minpath(P,V,V').           [1,true]


%%%#heuristic move(P,V,V')      : on_minpath(P,V,V').           [1,true]
%%%#heuristic move(P,V,V')      : path(P,_), edge(V,V',_),
%%%                               not on_minpath(P,V,V').       [1,false]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
