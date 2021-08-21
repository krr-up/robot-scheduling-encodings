% ------------------------------------------------------------------------------
% If we have precomputed shortest path information (shortest_path/4) and minimum
% path information (path_minpath/2). Generate moves based only on the minimum
% path.
%
% Input: path_minpath/2, shortest_path/4.
% Output: move/3.
% ------------------------------------------------------------------------------

#include "minpath.lp".

% ------------------------------------------------------------------------------
% Pick moves from the minimum paths
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_), path_minpath(P,V') } 1 :-
                                               path_minpath(P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_minpath(P,V) } 1 :-
                                               path_minpath(P,V'), edge(V',_,_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
