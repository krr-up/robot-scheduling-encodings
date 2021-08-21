%------------------------------------------------------------------------------
%
%            w2
%          /    \
% (r1:s) w1      w4  (r2:s)
% (r1:e)   \    /    (r2:e)
%            w3
%
% Robots with tasks to pickup/putdown at opposite ends
%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w4,15).
edge(w1,w3,15).
edge(w3,w4,15).

robot(r1). start(r1,w1). home(r1,w1).
robot(r2). start(r2,w4). home(r2,w4).

task(t1,w1). task(t2,w4).
task(t3,w4). task(t4,w1).

depends(deliver,t1,t2).
depends(deliver,t3,t4).

%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL

