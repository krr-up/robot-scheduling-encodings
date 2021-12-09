% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations. Only applied to domain predicate calculated
% minpaths/corridors.
% ------------------------------------------------------------------------------
%#include "minpath2.lp".
%#include "move_choice_corr.lp"

#heuristic move(P,V,V')  : path_minpath_d(P,V), path(P,V''),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : path_corr_d(P,V), edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

