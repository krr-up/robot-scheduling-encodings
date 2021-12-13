% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations. Distinguish between domain and non-domain minpath
% calculations.
% ------------------------------------------------------------------------------
#include "minpath.lp".


#heuristic move(P,V,V')  : path_minpath_d(P,V), path(P,V''),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : path_minpath_nd(P,V), path(P,V''),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
