% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations.
% ------------------------------------------------------------------------------

#include "move_choice_minpath.lp".

%#heuristic move(P,V,V')      : on_minpath(P,V,V').           [1,sign]
#heuristic move(P,V,V')      : on_minpath(P,V,V').           [2,factor]

%#heuristic move(P,V,V')      : path(P,_), edge(V,V',_),
%                               not on_minpath(P,V,V').       [-1,sign]
%#heuristic move(P,V,V')      : path(P,_), edge(V,V',_),
%                               not on_minpath(P,V,V').       [2,factor]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
