% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations. Handle both domain and non-domain predicate based moves.
% ------------------------------------------------------------------------------
% #include "minpath.lp".
% #include "move_choice_corr.lp"

#heuristic move(P,V,V')  : path_corr_d(P,V), edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]

#heuristic move(P,V,V')  : path_corr(_,P,V), edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

