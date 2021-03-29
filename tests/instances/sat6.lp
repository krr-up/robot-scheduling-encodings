%------------------------------------------------------------------------------
%
%            w2
%          /
% (r1:s) w1
% (r1:e)   \
%            w3
%
% Robot at it home positions with final task at home position
%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w1,w3,15).

robot(r1). start(r1,w1). home(r1,w1).

task(t1,w2). task(t2,w1).

depends(deliver,t1,t2).

%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL
