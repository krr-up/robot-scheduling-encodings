% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations. Doesn't distinguish domain and non-domain predicates.
% ------------------------------------------------------------------------------
%#include "minpath_limited.lp".


#heuristic move(P,V,V')  : path_minpath(P,V), path(P,V''),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : path_corr(P,V), edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
