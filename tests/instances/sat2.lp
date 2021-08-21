% -----------------------------------------------------------------------------
% Sat
%
% (r1:s) -> (r1:e)
%   w1 ----- w2 ----- w3
%        (r2:s) -> (r2:e)
%
% -----------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w3,15).

robot(r1). start(r1,w1). home(r1,w2).
robot(r2). start(r2,w2). home(r2,w3).

#defined task_sequence/2.
#defined depends/3.
#defined assignment/2.
#defined task/2.


