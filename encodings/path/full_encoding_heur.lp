% ------------------------------------------------------------------------------
% Domain heuristics for the path encoding.
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

on_minpath(R,Src,V)     :- start(R,Src), not path_sequence(_,R), path(R,Dest),
                           shortest_path(Src,Dest,_,V).
on_minpath(P',Src,V)    :- path_sequence(P,P'), path(P,Src), path(P',Dest),
                           shortest_path(Src,Dest,_,V).
on_minpath(P,Src,V)     :- on_minpath(P,_,Src), path(P,Dest),
                           shortest_path(Src,Dest,_,V).

% ------------------------------------------------------------------------------
% Domain heuristic for moves based on being on the shortest path
% ------------------------------------------------------------------------------

#heuristic move(P,V,V')      : on_minpath(P,V,V').           [1,true]
#heuristic move(P,V,V')      : path(P,_), edge(V,V',_),
                               not on_minpath(P,V,V').       [1,false]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
