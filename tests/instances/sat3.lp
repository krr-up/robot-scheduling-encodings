%------------------------------------------------------------------------------
%
%            w2
%          /    \
% (r1:s) w1      w4  (r1:e)
% (r2:e)   \    /    (r2:s)
%            w3
%
% Swap robots at w1 and w4.
%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w4,15).
edge(w1,w3,15).
edge(w3,w4,15).

robot(r1). start(r1,w1). home(r1,w4).
robot(r2). start(r2,w4). home(r2,w1).

%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL


#defined task_sequence/2.
#defined depends/3.
#defined assignment/2.
#defined task/2.
#defined walk/3.
