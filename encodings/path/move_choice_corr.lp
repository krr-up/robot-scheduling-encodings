% ------------------------------------------------------------------------------
% Perform move selection based on the definition of a corridor. path_corr_d/2
% and path_corr/3 definitions.  Similar to move_choice_corr.lp but separating
% the domain from non-domain predicates and define a domain grounding of
% possible corridors for the corridors that can't be determined at grounding.
%
% Input: path_minpath/2, shortest_path/4.
% Output: path_corr/2, move/3.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Pick moves for paths that have domain predicate corridors path_corr_d/2.
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_), path_corr_d(P,V') } 1 :-
                                                 path_corr_d(P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_corr_d(P,V) } 1 :-
                                                 path_corr_d(P,V'), edge(_,V',_).

% ------------------------------------------------------------------------------
% For pickup tasks where the starting location can vary depending on the task
% sequence, the move choice is defined in terms of path_corr/3 and edge/3 (which
% are both domain predicates). Constraints are then defined in terms of the
% non-domain predicate path_sequence/2 that restrict the moves to the actual
% task sequences.
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
