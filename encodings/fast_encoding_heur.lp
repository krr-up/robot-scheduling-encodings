% ------------------------------------------------------------------------------
% Domain heuristics for the path encoding.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% If we have precomputed shortest path information (in the form of the
% shortest_path/4 predicate) then we can calculate the minimum path for each
% path as well as a minimum duration/distance. These can be used by the domain
% heuristics.
% ------------------------------------------------------------------------------

% The next edge between vertices along the shortest path from src to dst.
on_minpath(R,Src,Via)    :- start(R,Src), not path_sequence(_,R), path(R,Dest),
                            shortest_path(Src,Dest,_,Via).
on_minpath(P',Src,Via)   :- path_sequence(P,P'), path(P,Src), path(P',Dest),
                            shortest_path(Src,Dest,_,Via).
on_minpath(P,Src,Via)    :- on_minpath(P,_,Src), path(P,Dest),
                            shortest_path(Src,Dest,_,Via).

%%%on_minpath(P,Src,V)         :- first_visit(P,Src), last_visit(P,Dst),
%%%                              shortest_path(Src,Dst,_,V).
%%%on_minpath(P,V,V')           :- on_minpath(P,_,V), last_visit(P,Dst),
%%%                                shortest_path(V,Dst,_,V').
%%%

% ------------------------------------------------------------------------------
% Domain heuristic for moves based on being on the shortest path
% ------------------------------------------------------------------------------

#heuristic move(P,V,V')      : on_minpath(P,V,V').           [1,true]
#heuristic move(P,V,V')      : path(P,_), edge(V,V',_),
                               not on_minpath(P,V,V').       [1,false]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
