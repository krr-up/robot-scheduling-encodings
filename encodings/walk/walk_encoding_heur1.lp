% ------------------------------------------------------------------------------
% Domain heuristics for the walk encoding.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% on_minpath(P,Src,Via) - for the robot executing the path P, if it is currently
% at Src then Via is on the minimum path to the destination for P.
% ------------------------------------------------------------------------------

on_minpath(R,0,V)     :- start(R,V), assignment(R,_).
on_minpath(R,S,V)     :- assignment(R,T), proj(T,S), task(T,V).

on_minpath(R,S+1,V')  :- on_minpath(R,S,V), assignment(R,T), proj(T,S''), S < S'',
                         task(T,Dst), shortest_path(V,Dst,_,V'),
                         #false : assignment(R,T'), proj(T',S'), S < S', S' <  S''.

#heuristic walk(R,S,V) : on_minpath(R,S,V).   [1,true]

#heuristic move(R,S,V)  : robot(R), step(S), edge(V,V',_),
                          not on_minpath(R,S,V).       [1,false]









%on_minpath(T,S+1,V)    :- walk(R,S,V), task(T,Dst), shortest_path(V,Dst,_,V').





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
