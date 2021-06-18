% ------------------------------------------------------------------------------
% Similar to move_choice_corr.lp but separating the domain from non-domain
% predicates to hopefully get better grounding.

% If we have precomputed shortest path information (shortest_path/4) and then
% calculated the minimum path (path_minpath/2). We can compute a corridor around
% the minimum path and restrict the moves to this corridor.
%
% Input: path_minpath/2, shortest_path/4.
% Output: path_corr/2, move/3.
% ------------------------------------------------------------------------------
#include "minpath2.lp".

% ------------------------------------------------------------------------------
% Limit the move selection to a "corridor" around the shortest path. The
% corridor is defined as follows: 1) the minimum path from the source to
% destination is on the corridor, 2) every node directly connected to a node on
% the minimum path is also on the corridor provided that the distance to the
% destination from that connected node is not greater than the distance from the
% minimum path node.
% ------------------------------------------------------------------------------

path_corr_nd(P,V) :- path(P,V), not depends(deliver,_,P).
path_corr_nd(P,V) :- path_minpath_nd(P,V).
path_corr_nd(P,V) :- path_minpath_nd(P,V), edge(V,V',_), path(P,V''),
                     shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.

path_corr_d(T,V) :- task(T,V), depends(deliver,_,T).
path_corr_d(T,V) :- path_minpath_d(T,V).
path_corr_d(T,V) :- path_minpath_d(T,V), edge(V,V',_), task(T,V''),
                    shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.

% ------------------------------------------------------------------------------
% Pick moves on the corridor
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_), path_corr_nd(P,V') } 1 :-
                                                 path_corr_nd(P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_corr_nd(P,V) } 1 :-
                                                 path_corr_nd(P,V'), edge(V',_,_).

0 { move(P,V,V') : edge(V,V',_), path_corr_d(P,V') } 1 :-
                                                 path_corr_d(P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_corr_d(P,V) } 1 :-
                                                 path_corr_d(P,V'), edge(V',_,_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
