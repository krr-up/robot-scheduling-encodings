% ------------------------------------------------------------------------------
% Use reachability to make sure that the moves for each path are not
% cyclic. Work backwards from the path destination (ie the predicate
% "path(P,V)") to the source.
% ------------------------------------------------------------------------------

path_reachable(P,V) :- path(P,V).
path_reachable(P,V) :- path_reachable(P,V'), move(P,V,V').
:- move(P,_,V), not path_reachable(P,V).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

