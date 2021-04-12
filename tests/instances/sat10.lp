%------------------------------------------------------------------------------
%
%          (r2:s) (r1:e)
%           w2
%          /  \
%         /    \
% (r1:s) w1----w3 (r3:s)
% (r3:e)          (r2:e)
%
% Three robots need to shift positions
%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w3,15).
edge(w3,w1,15).

robot(r1). start(r1,w1). home(r1,w2).
robot(r2). start(r2,w2). home(r2,w3).
robot(r3). start(r3,w3). home(r3,w1).

%task(t1,w2). task(t2,w3).

%depends(deliver,t1,t2).

%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL

#defined task/2.
#defined depends/3.
