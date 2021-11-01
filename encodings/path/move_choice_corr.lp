% ------------------------------------------------------------------------------
% Similar to move_choice_corr.lp but separating the domain from non-domain
% predicates and define a domain grounding of possible corridors for the
% corridors that can't be determined at grounding.
%
% Input: path_minpath/2, shortest_path/4.
% Output: path_corr/2, move/3.
% ------------------------------------------------------------------------------
#include "minpath.lp".

% ------------------------------------------------------------------------------
% Limit the move selection to a "corridor" around the shortest path. For putdown
% paths the corridor can be ground out. In such cases the corridor is defined
% as follows: 1) the minimum path from the source to destination is on the
% corridor, 2) every node directly connected to a node on the minimum path is
% also on the corridor provided that the distance to the destination from that
% connected node is not greater than the distance from the minimum path node.
% ------------------------------------------------------------------------------

path_corr_d(T,V)  :- task(T,V), depends(deliver,_,T).
path_corr_d(T,V)  :- path_minpath_d(T,V).
path_corr_d(T,V') :- path_minpath_d(T,V), edge(V,V',_), task(T,V''),
                     shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.

% ------------------------------------------------------------------------------
% Pick moves for paths that have domain predicate corridors
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_), path_corr_d(P,V') } 1 :-
                                                 path_corr_d(P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_corr_d(P,V) } 1 :-
                                                 path_corr_d(P,V'), edge(_,V',_).

% ------------------------------------------------------------------------------
% For pickup tasks the starting location can vary depending on the task
% sequence. So we can't define the corridor using only domain
% predicates. Instead define a non-domain path corridor and separately define a
% larger grounding that encompasses all possibilities. The move choice is then
% defined over the domain grounding and subsequently restricted to the
% non-domain corridor.
% ------------------------------------------------------------------------------

path_corr(P,P',V)  :- path_minpath(P,P',V).
path_corr(P,T,V') :- path_corr(P,T,V), edge(V,V',_), task(T,V''),
                       shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.
path_corr(P,R,V') :- path_corr(P,R,V), edge(V,V',_), home(R,V''),
                       shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.

% ------------------------------------------------------------------------------
% Pick moves for paths that have from-to path corridors that are domain
% predicates and then restrict the moves to the non-domain path corridors.
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_), path_corr(_,P,V') } 1 :-
                                          path_corr(_,P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_corr(_,P,V) } 1 :-
                                          path_corr(_,P,V'), edge(_,V',_).
:- robot(R), not path(R,_), move(R,_,_).

:- move(P',V,V'), path_sequence(P,P'), path_corr(_,P',_),
   not path_corr(P,P',V), not path_corr(P,P',V').

:- move(R,V,V'), robot(R), not assignment(R,_),
   not path_corr(R,R,V), not path_corr(R,R,V').


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
