% -----------------------------------------------------------------------------
% Unsat because it requires one robot to overtake the other
%
% (r1:s) ------------------> (r1:e)
%   w1 ----- w2 ----- w3 ----- w4
%        (r2:s) -> (r2:e)
%
% -----------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w3,15).
edge(w3,w4,15).

robot(r1). start(r1,w1). home(r1,w4).
robot(r2). start(r2,w2). home(r2,w3).


