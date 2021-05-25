% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations.
% ------------------------------------------------------------------------------

#include "move_choice_minpath.lp".

% Set any move not on the shortest path to false
#heuristic move(P,V,V')  : path(P,_), edge(V,V',_), not on_minpath(P,V,V'). [1,false]


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

