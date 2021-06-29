% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations. Handle both domain and non-domain predicate based moves.
% ------------------------------------------------------------------------------
% #include "minpath2.lp".
% #include "move_choice_corr2.lp"

#heuristic move(P,V,V')  : path_minpath_d(P,V), path(P,V''),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : path_corr_d(P,V), edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]


#heuristic move(P,V,V')  : path_minpath_nd(P,V), path(P,V''),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : path_corr(_,P,V), edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

