%------------------------------------------------------------------------------
% Unsat because it requires robots to swap positions to get to their homes.
%
% (r1:s) ----------> (r1:e)
%   w1 ----- w2 ----- w3
% (r2:e) <---------- (r2:s)
%
%------------------------------------------------------------------------------

#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w3,15).

robot(r1). start(r1,w1). home(r1,w3).
robot(r2). start(r2,w3). home(r2,w1).
