%------------------------------------------------------------------------------
%
% (r1:s) w1 --- w2
%                \     (r2:e)   (r1:e)
%                 w5 --- w6 ---- w7
%                /
% (r2:s) w3 --- w4
%
% Conflict edge (w2,w4) and (w3,w4)
%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15). edge(w2,w5,15).
edge(w3,w4,15). edge(w4,w5,15). edge(w5,w6,15). edge(w6,w7,15).

robot(r1). start(r1,w1). home(r1,w7).
robot(r2). start(r2,w3). home(r2,w6).

conflict(e,(w2,w5),(w4,w5)).


%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL

#defined task/2.
#defined depends/3.
