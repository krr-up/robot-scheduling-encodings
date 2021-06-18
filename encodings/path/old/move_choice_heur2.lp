% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations.
% ------------------------------------------------------------------------------

#include "minpath2.lp".

% Higher factor values for vertices on the minpath the closer they are to the
% start or end of a path.
factor(P,Cur,|X-X'|)     :- on_minpath(P,Cur,_), first_visit(P,Src), last_visit(P,Dst),
                            shortest_path(Cur,Dst,X,_), shortest_path(Cur,Src,X',_).

#heuristic move(P,V,V')  : on_minpath(P,V,V').                              [1,sign]
#heuristic move(P,V,V')  : on_minpath(P,V,V'), factor(P,V,X).               [X,factor]

#heuristic move(P,V,V')  : path(P,_), edge(V,V',_), not on_minpath(P,V,V'). [1,false]

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
