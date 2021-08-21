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

%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL
#defined walk/3.

#defined task/2.
#defined depends/3.
#defined assignment/2.
#defined task_sequence/2.

