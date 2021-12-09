% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations. Only compute heuristic for moves that can be determined purely
% from domain predicates.
% ------------------------------------------------------------------------------
% #include "minpath_limited.lp".

#heuristic move(P,V,V')  : path_minpath(P,V), path(P,V''),
                           depends(deliver,_,P),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : path_corr(P,V), edge(V,V',_), path(P,V''),
                           depends(deliver,_,P),
                           not shortest_path(V,V'',_,V').           [1,false]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
