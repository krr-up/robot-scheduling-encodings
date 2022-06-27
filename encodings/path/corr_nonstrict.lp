% ------------------------------------------------------------------------------
% Define a corridor for each path, based on the shortest path between
% vertices. This allows us to restrict the move selection to the corridor.  This
% can make a huge difference to the grounding.
%
% There are many possible definitions of a corridor but we only consider two
% fairly restricted definitions here. We call them the strict and a nonstrict
% version (even though the nonstrict version is also quite restricted).
%
% For both definitions we consider every vertex on the shortest path as part of
% the corridor. In the non-strict version every vertex directly connected to a
% shortest path vertex is part of the corridor. In the strict version every
% vertex directly connected to a shortest path vertex is part of the corridor
% only if it is no further away from the destination vertex than its connected
% shortest path vertex.
%
% The strict version works well on graphs with diagonals, as it provides move
% choices but rules out pathalogical cases. However on a grid the strict version
% doesn't work well and can end up restriction the corridor to only the shortest
% paths themselves. The non-strict version works better in these cases (although
% it potentially allows for some pathological graph cases).
%
% Input: path_minpath/2, shortest_path/4.
% Output: path_corr_d/2, path_corr/3
% ------------------------------------------------------------------------------
#include "minpath.lp".

% path_corr_d/2 is for tasks where the previous task is fixed. For example a
% putdown task of an item must alway be preceded by the pickup task for that
% item.

path_corr_d(T,V)  :- path_minpath_d(T,V).
path_corr_d(T,V') :- path_minpath_d(T,V), edge(V,V',_), task(T,V''),
                     shortest_path(V,V'',N,_), shortest_path(V',V'',N',_).


% path_corr/3 is for tasks where the previous task is not
% fixed. path_corr(P1,P2,V) can be read as if (for some robot) path path P1 is
% followed by path P2, then V is on the corridor.

path_corr(P,P',V)  :- path_minpath(P,P',V).
path_corr(P,T,V') :- path_corr(P,T,V), edge(V,V',_), task(T,V''),
                       shortest_path(V,V'',N,_), shortest_path(V',V'',N',_).
path_corr(P,R,V') :- path_corr(P,R,V), edge(V,V',_), home(R,V''),
                       shortest_path(V,V'',N,_), shortest_path(V',V'',N',_).
