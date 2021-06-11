% ------------------------------------------------------------------------------
% If we have precomputed shortest path information (in the form of the
% shortest_path/4) then we can track the minimum path for each task-path object
% and restrict the moves of each path to a corridor around the minimum path.
%
% Input: start/2, task_sequence/2, path_sequence/2, path/2, shortest_path/4, edge/3.
% Output: path_on_minpath/2, path_corr/2, move/3.
%
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Limit the move selection to a "corridor" around the shortest path. The
% corridor is defined as follows: 1) the minimum path from the source to
% destination is on the corridor, 2) every node directly connected to a node on
% the minimum path is also on the corridor provided that the distance to the
% destination from that connected node is not greater than the distance from the
% minimum path node.
% ------------------------------------------------------------------------------

% The starting vertex of a path is always on the minimum path. Three cases:
% 1) robot with no assignments returning home, 2) first in the task sequence,
% 3) non-first path.

path_on_minpath(R,V)   :- start(R,V), not assignment(R,_), path(R,_).
path_on_minpath(T,V)   :- start(R,V), assignment(R,T), not task_sequence(_,T).
path_on_minpath(P',V)  :- path_sequence(P,P'), path(P,V).

path_on_minpath(P,V'') :- path_on_minpath(P,V), path(P,V'), shortest_path(V,V',_,V'').

path_corr(P,V) :- path(P,V).
path_corr(P,V) :- path_on_minpath(P,V).
path_corr(P,V) :- path_on_minpath(P,V), edge(V,V',_), path(P,V''),
                  shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.

0 { move(P,V,V') : edge(V,V',_), path_corr(P,V') } 1 :- path_corr(P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_corr(P,V) } 1 :- path_corr(P,V'), edge(V',_,_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------


%%#heuristic move(P,V,V') : path_on_minpath(P,V), path(P,V''),
%%                          shortest_path(V,V'',_,V'), V != V'. [1,true]

%%#heuristic move(P,V,V') : path_corr(P,V), not path_on_minpath(P,V), path(P,V''),
%%                          shortest_path(V,V'',_,V'), V != V'. [1,false]
